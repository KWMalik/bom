
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
  def get_recent_day_contiguous_summary
    summary = {}
    # assume 4 days for now
    num_days = 4
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
    # bounds
    min, max = union.min, union.max
    # make the graph
    return make_multi_series_graph(temps, get_time_labels_one_day_graph, min, max, title)
  end  
  
  # contiguous graph over recent days
  # assumes all days are there for all datasets
  def get_recent_days_contiguous_graph(title)
    return "" if @dataset.keys.length == 0
    # temperature datasets for graphing
    temps = {}
    # union of temps for bounds 
    union = []  
    # assume last 4 days for now
    num_days = 4
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
    # bounds
    min, max = union.min, union.max    
    # make the graph
    return make_multi_series_graph(temps, multi_day_labels(num_days), min, max, title)
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

end
