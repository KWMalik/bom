
class Graph

  attr_reader :dataset

  def initialize 
    @dataset = {}
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
  
  # make a multi-series graph
  # expect data to be complete in [key][temps] format
  def make_multi_series_graph(datasets, xlabels, min_temp, max_temp, title)
    ordered_series = datasets.keys.sort
    base = ""
    # url
    base << "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=#{html_colors(datasets.keys.length).join(',')}&"
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
  
  # get a list of html colors for graph serieses
  def html_colors(total)
    all_colors = ["FF0000", "00FF00", "0000FF", "00FFFF", "FF00FF", "FFFF00", "000000"]
    #return [] if total > all_colors.length
    return Array.new(total){|i| all_colors[i]}
  end  

end
