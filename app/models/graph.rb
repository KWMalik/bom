
class Graph

  attr_reader :dataset

  def initialize 
    @dataset = {}
    @counter = 1
  end
  
  # a summary of todays temperature
  def get_today_summary
    summary = {}
    # all datasets for today
    datasets = get_today_datasets
    return summary if datasets.keys.empty?
    datasets.keys.each do |set|
      summary[set] = make_summary_row(datasets[set])
    end
    return summary    
  end
  
  # a summary of recent days temperature, by day
  def get_recent_days_summary
    summary = {}
    # process datasets
    @dataset.keys.each do |station|
      @dataset[station].keys.each do |date|
        key = date.strftime("%d/%m/%Y")
        raise "date conflict in datasets for #{date}" if !summary[key].nil?
        summary[key] = make_summary_row(@dataset[station][date])
      end
    end    
    return summary
  end
  
  # a summary of recent days temperature, contiguous by station
  # assumes 4 days because that what the bom provides
  def get_recent_day_contiguous_summary(num_days=4)
    summary = {}
    # process datasets
    @dataset.keys.each do |station|
      next if @dataset[station].keys.length != num_days
      master = []
      ordered_dates = @dataset[station].keys.sort
      ordered_dates.each do |date|
        master += @dataset[station][date]
      end
      summary[station] = make_summary_row(master)
    end    
    return summary
  end
  
  # make a summary of a given dataset [][label, count, temp]
  def make_summary_row(dataset)
    summary = {}
    temps = []
    dataset.each {|rec| temps << rec[:temp] if rec[:count]>0 }
    summary[:total] = dataset.inject(0){|sum, rec| sum+rec[:count]}
    summary[:min] = temps.min
    summary[:max] = temps.max
    summary[:mean] = temps.sum/temps.length.to_f
    first = dataset.find {|rec| rec[:count]>0}
    last = dataset.reverse.find {|rec| rec[:count]>0}
    summary[:last_temp] = last[:temp]
    return summary
  end

  # data[key][date][label, count, temp]
  def add_dataset(set)
    set.keys.each do |key|
      raise "dataset #{key} already added, cannot add again." if !@dataset[key].nil?
      @dataset[key] = set[key]
    end
  end
  
  
  def is_today?(date)
    return date.day == Date.today.day
  end
  
  def get_today_datasets
    sets = {}
    @dataset.keys.each do |key|
      # only one today for each dataset
      @dataset[key].keys.each do |date|
        if is_today?(date)
          raise "cannot add series for today, already exists for dataset #{key}" if !sets[key].nil?
          sets[key] = @dataset[key][date]
        end        
      end
    end    
    return sets
  end
  
  # graph of all datasets for today
  def get_today_graph(title)
    # all datasets for today
    datasets = get_today_datasets
    return "" if datasets.keys.length == 0
    # temperature datasets for graphing
    temps = {}
    # union of temps for bounds 
    union = []    
    # process datasets
    datasets.keys.each do |key|
      temps[key] = []
      datasets[key].each do |record|
        temps[key] << ((record[:count]>0) ? record[:temp].round(2) : '_')
        union << record[:temp] if record[:count] > 0
      end
    end
    # bounds
    min, max = union.min, union.max
    # make the graph
    return make_multi_series_graph(temps, get_time_labels_one_day_graph, min, max, title)
  end
  
  # graph of all datasets for recent days (all days for all datasets)
  def get_recent_days_graph(title)
    # no data check
    return "" if @dataset.keys.length == 0
    # temperature datasets for graphing
    temps = {}
    # union of temps for bounds 
    union = []    
    # process datasets
    @dataset.keys.each do |station|
      @dataset[station].keys.each do |date|
        key = date.strftime("%d/%m/%Y")
        raise "date conflict in datasets for #{date}" if !temps[key].nil?
        temps[key] = []
        @dataset[station][date].each do |record|
          if record[:count] > 0 
            temps[key] << record[:temp].round(2)
            union << record[:temp]
          else
            temps[key] << "_"
          end
        end
      end
    end    
    # no prep'ed data check
    return "" if temps.keys.length == 0    
    # bounds
    min, max = union.min, union.max
    # make the graph
    return make_multi_series_graph(temps, get_time_labels_one_day_graph, min, max, title)
  end  
  
  # contiguous graph over recent days
  # assumes all days are there for all datasets
  # assume 4 days for now, that is what the bom provides
  def get_recent_days_contiguous_graph(title, num_days=4)
    # no data check
    return "" if @dataset.keys.length == 0
    # temperature datasets for graphing
    temps = {}
    # union of temps for bounds 
    union = []  
    @dataset.keys.each do |station|
      next if @dataset[station].keys.length != num_days
      ordered_dates = @dataset[station].keys.sort
      temps[station] = []
      ordered_dates.each do |date|
        @dataset[station][date].each do |record|
          if record[:count] > 0 
            temps[station] << record[:temp].round(1)
            union << record[:temp]
          else
            temps[station] << "_"
          end
        end        
      end
    end
    # no prep'ed data check
    return "" if temps.keys.length == 0
    # bounds
    min, max = union.min, union.max    
    # make the graph
    return make_multi_series_graph(temps, multi_day_labels(num_days), min, max, title)
  end
  
  # boxplot of all days for a station
  def get_recent_days_boxplot_graph(station, title)
    # no data check
    return "" if @dataset.keys.length == 0  
    data = {}
    data[:min] = []
    data[:max] = []
    data[:q1] = []
    data[:q3] = []
    data[:med] = []
    # process
    ordered_days = @dataset[station].keys.sort
    labels = []
    union = []
    ordered_days.each do |date|
      # get temps
      temps = []
      @dataset[station][date].each {|r| temps << r[:temp] if r[:count]>0 }
      # skip empty days, breaks the graph
      next if temps.empty?
      labels << date.strftime("%d/%m/%Y")
      # add to union
      union += temps
      # stats
      data[:min] << temps.min
      data[:max] << temps.max
      data[:q1] << excel_lower_quartile(temps)
      data[:q3] << excel_upper_quartile(temps)
      data[:med] << excel_middle_quartile(temps)
    end
    # no prep'ed data check
    return "" if data[:min].length == 0    
    # bounds
    min, max = union.min, union.max
    # make the graph
    return make_boxplot_graph(data, labels, min, max, title)
  end
  
  # make a multi-series graph
  # expect data to be complete in [key][temps] format
  def make_multi_series_graph(datasets, xlabels, min_temp, max_temp, title)
    ordered_series = datasets.keys.sort
    base = ""
    # url
    base << next_chart_url
    # graph type
    base << "cht=lc&"    
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=#{html_colors(datasets.keys.length).join(',')}&"
    # graph title
    base << "chtt=#{title}&"
    # visible axes
    base << "chxt=x,y&"
    # axis ranges    
    base << "chxr=1,#{min_temp},#{max_temp},#{(max_temp-min_temp)/10.0}&"
    # range for scaling data
    base << "chds=#{min_temp},#{max_temp}&"
    # axis labels
    base << "chxl=0:|#{xlabels.join('|')}&"
    # length of ticks
    base << "chxtc=0,8&"
    # data legend
    base << "chdl=#{ordered_series.join('|')}&"
    # data
    serieses = []
    ordered_series.each {|key| serieses << datasets[key].join(',') }
    base << "chd=t:#{serieses.join('|')}"
    
    puts "DEBUG: graph length = #{base.length}"
    return base
  end
  
  
  # make a boxplot of the provided data
  # in: data[min, max, q1, q3, med] where,
  #   each ref has an array and each member across arrays is for the one series
  def make_boxplot_graph(data, xlabels, min_temp, max_temp, title) 
    num = data[data.keys.first].length
    # inset data
    data.keys.each do |k| 
      data[k].unshift(-1)
      data[k].push(-1)
    end
    # inset labels
    xlabels.unshift("")
    xlabels.push("")
    # build url   
    base = ""
    # url
    base << next_chart_url    
    # graph size
    base << "chs=600x240&"
    # graph title
    base << "chtt=#{title}&"
    # graph type
    base << "cht=lc&"
    # visible axes
    base << "chxt=x,y&"
    # axis ranges    
    base << "chxr=1,#{min_temp},#{max_temp},#{(max_temp-min_temp)/10.0}&"
    # range for scaling data
    base << "chds=#{min_temp},#{max_temp}&"
    # axis labels
    base << "chxl=0:|#{xlabels.join('|')}&"
    # build series
    serieses = []
    serieses << data[:min].join(',')
    serieses << data[:q1].join(',')
    serieses << data[:q3].join(',')
    serieses << data[:max].join(',')
    serieses << data[:med].join(',')
    base << "chd=t0:#{serieses.join('|')}&"    
    # build display
    display = []
    display << "F,FF0000,0,1:#{num},40"
    display << "H,FF0000,0,1:#{num},1:20"
    display << "H,FF0000,3,1:#{num},1:20"
    display << "H,000000,4,1:#{num},1:40"
    base << "chm=#{display.join('|')}"

    puts "DEBUG: graph length = #{base.length}"
    return base
  end
  
  
  # for drawing multiple charts from this graph object
  # avoid all using http://chart.apis.google.com/chart?
  def next_chart_url
    # does not work for now!?!?!
    return "http://chart.apis.google.com/chart?"
    #url = "http://#{@counter}.chart.apis.google.com/chart?"
    #@counter += 1
    #@counter = 0 if @counter > 9
    #return url
  end

  # labels for 24 hours
  def self.times_full_day
    am, pm = [], []
    12.times do |i|
      hour = (i==0) ? "12" : ((i<10) ? "0#{i}" : i.to_s)
      am << "#{hour}:00am"
      am << "#{hour}:30am"
      pm << "#{hour}:00pm"
      pm << "#{hour}:30pm"
    end
    return am+pm
  end
  
  # time labels suitable for a one day graph
  def get_time_labels_one_day_graph
    return ["12:00am", "03:00am", "06:00am", "09:00am", "12:00pm", "03:00pm", "06:00pm", "09:00pm", "12:00am"]
  end  
  
  # labels for multiple day graph (midnight to midnight)
  def multi_day_labels(num_days)
    labels = []
    num_days.times do |i|
      labels << "12:00am"
      labels << "12:00pm"
    end
    labels << "12:00am"
    return labels
  end  
  
  # get a list of html colors for graph serieses
  def html_colors(total)
    all_colors = ["FF0000", "00FF00", "0000FF", "00FFFF", "FF00FF", "FFFF00", "000000"]
    #return [] if total > all_colors.length
    return Array.new(total){|i| all_colors[i]}
  end  

  
  # IQR calculations for boxplots
  # http://stackoverflow.com/questions/1744525/ruby-percentile-calculations-to-match-excel-formulas-need-refactor
  def excel_quartile(array, quartile)
    # Returns nil if array is empty and covers the case of array.length == 1
    return array.first if array.length <= 1
    sorted = array.sort
    # The 4th quartile is always the last element in the sorted list.
    return sorted.last if quartile == 4
    # Source: http://mathworld.wolfram.com/Quartile.html
    quartile_position = 0.25 * (quartile*sorted.length + 4 - quartile)
    quartile_int = quartile_position.to_i
    lower = sorted[quartile_int - 1]
    upper = sorted[quartile_int]
    lower + (upper - lower) * (quartile_position - quartile_int)
  end

  def excel_lower_quartile(array)
    excel_quartile(array, 1)
  end

  def excel_upper_quartile(array)
    excel_quartile(array, 3)
  end
  
  def excel_middle_quartile(array)
    excel_quartile(array, 2)
  end 
end
