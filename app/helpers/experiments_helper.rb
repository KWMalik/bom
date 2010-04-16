module ExperimentsHelper

  #
  # summary of sensor data.
  # expects: data[]{:data,:sensors[...]}
  #
  def sensor_summary_graph(data, title)  
    temp_union = []
    datasets = {}
    temps = {}
    # process sensor data (if provided)
    if !data.nil? and !data.empty?
      data.each do |r|
        bins = descretize_sensor_data(r[:sensors])
        key = r[:date].strftime("%d/%m")
        datasets[key], temps[key] = [], []
        bins.each do |record| 
          if record[:count] > 0
            t = record[:temp] / record[:count].to_f
            temp_union << t.round(3)
            datasets[key] << t.round(3)
            temps[key] << t.round(3)
          else 
            datasets[key] << '_'
          end
        end
      end
    end     
    min, max = temp_union.min, temp_union.max
    range = max-min

    
    ordering = datasets.keys.sort
    labels = []

    data = {}
    data[:min] = []
    data[:max] = []
    data[:q1] = []
    data[:q3] = []
    data[:med] = []
        
    data.keys.each {|k| data[k] << -1}    
    labels << ""
    ordering.each do |key|
      next if temps[key].empty?
      labels << key
      data[:min] << temps[key].min
      data[:max] << temps[key].max
      data[:q1] << excel_lower_quartile(temps[key])
      data[:q3] << excel_upper_quartile(temps[key])
      data[:med] << excel_middle_quartile(temps[key])
    end
    data.keys.each {|k| data[k] << -1}
    labels << ""
    
    num = data[:min].length - 1
  
    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # graph title
    base << "chtt=Sensor Temperatures: #{title}&"
    # graph type
    base << "cht=lc&"
    # visible axes
    base << "chxt=x,y&"
    # axis ranges
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"
    # range for scaling data
    base << "chds=#{min},#{max}&"
    # axis labels
    base << "chxl=0:|#{labels.join('|')}&"
    # data legend
    #base << "chdl=#{ordering.join('|')}&"
    
    

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
        
    return base
  end
  
  #
  # a number of contigious days concat together in a single series
  #  
  def make_multi_day_sequence_graph_img_url(data)
    # create temp arrays and a union of all temps
    temps = {}
    temps_union = []
    data.keys.each do |key|
      temps[key] = []
      data[key].each do |v|
        if v[0].nil?
          temps[key] << '_'
        else
          temps[key] << v[0].to_f
          temps_union << v[0].to_f
        end

      end      
    end
    # create temp summary values
    min, max, avg = temps_union.min, temps_union.max, (temps_union.sum/temps_union.size.to_f)
    range = max-min
    summary = [min, avg, max]
    # scale
    temps.keys.each do |key|
      temps[key].each_with_index do |v,i|
        next if v == '_'
        temps[key][i] = (((v-min)/range)*100.0).round(3)
      end 
    end
    summary.each_with_index {|v,i| summary[i] = (((v-min)/range)*100.0).round(3)}

    # sort by full date
    keys = data.keys
    keys.sort!{|x,y| data[x][0][2].to_i<=>data[y][0][2].to_i}
    
    #block out oldest day
    (48-temps[keys.first].length).times { temps[keys.first].unshift("_")}
    # block out today
    (48-temps[keys.last].length).times { temps[keys.last] << "_" }
    # labels (really rough, may not be accurate)
    time_labels = ["12:00am", "12:00pm", "12:00am", "12:00pm", "12:00am", "12:00pm", "12:00am", "12:00pm"]
    
    #build master temp list
    all_temps = []
    keys.each do |key|
      all_temps += temps[key]
    end

    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=#{html_colors(1).join(',')}&"
    # graph title
    base << "chtt=Temperatures (last 4 days)&"
    # graph type
    base << "cht=lc&"
    # visible axes
    base << "chxt=x,y,r&"
    # axis label styles
    base << "chxs=2,0000DD,9,-1,t,CCCCCC&"
    # axis tick mark styles
    base << "chxtc=0,10|1,10|2,-600&"    
    # axis ranges
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"  
    # axis labels
    base << "chxl=0:|#{time_labels.join('|')}|2:|min|mean|max|&"
    # axis label positions
    base << "chxp=2,#{summary.join(',')}&"
    base << "chd=t:#{all_temps.join(',')}"
        
    return base    
  end
  
  #
  # a number of contigious days, each a separate series
  #
  def make_multiday_temp_graph_img_url(data)
    # create temp arrays and a union of all temps
    temps = {}
    temps_union = []
    data.keys.each do |key|
      temps[key] = []
      data[key].each do |v|
        if v[0].nil?
          temps[key] << '_'
        else
          temps[key] << v[0].to_f
          temps_union << v[0].to_f
        end

      end      
    end
    # create temp summary values
    min, max, avg = temps_union.min, temps_union.max, (temps_union.sum/temps_union.size.to_f)
    range = max-min
    summary = [min, avg, max]
    # scale
    temps.keys.each do |key|
      temps[key].each_with_index do |v,i|
        next if v == '_'
        temps[key][i] = (((v-min)/range)*100.0).round(3)
      end 
    end
    summary.each_with_index {|v,i| summary[i] = (((v-min)/range)*100.0).round(3)}

    # sort by full date
    keys = data.keys
    keys.sort!{|x,y| data[x][0][2].to_i<=>data[y][0][2].to_i}
    
    #block out oldest day
    (48-temps[keys.first].length).times { temps[keys.first].unshift("_")}
    # block out today
    (48-temps[keys.last].length).times { temps[keys.last] << "_" }
    # labels
    time_labels = get_time_labels


    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=#{html_colors(keys.length).join(',')}&"
    # graph title
    base << "chtt=Temperatures (last 4 days)&"
    # graph type
    base << "cht=lc&"
    # visible axes
    base << "chxt=x,y,r&"
    # axis label styles
    base << "chxs=2,0000DD,9,-1,t,CCCCCC&"
    # axis tick mark styles
    base << "chxtc=0,10|1,10|2,-600&"    
    # axis ranges
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"  
    # axis labels
    base << "chxl=0:|#{get_time_labels.join('|')}|2:|min|mean|max|&"
    # axis label positions
    base << "chxp=2,#{summary.join(',')}&"

    # all 4 days
    base << "chdl=#{keys.join("|")}&"
    base << "chd=t:"
    keys.each_with_index do |key,i|
      base << temps[key].join(',')
      base << "|" if i < (keys.length-1)
    end
        
    return base
  end
  

  #
  # graph one day's temperature
  #
  def make_day_temp_graph_img_url(data, title="Temperature")
    # array of temp data
    temp, union = [], []
    data.each do |rec| 
      if rec[0].nil?
        temp << '_'
      else      
        temp << rec[0].to_f
        union << rec[0].to_f
      end
    end
    # summary data
    min, max, avg = union.min, union.max, union.sum/union.size.to_f
    range = max-min
    summary = [min, max, avg]    
    # scale manually
    temp.each_with_index do |v,i| 
      next if v == '_'
      temp[i] = (((v-min)/range)*100.0).round(3)
    end
    summary.each_with_index {|v,i| summary[i] = (((v-min)/range)*100.0).round(3)}
    
    # block out the remainder of the temps for the day as nulls
    (48-temp.length).times { temp << "_"}
    time_labels = get_time_labels
    
    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=#{html_colors(1).join(',')}&"
    # graph title
    base << "chtt=#{title}&"
    # graph type
    base << "cht=lc&"
    # visible axes
    base << "chxt=x,y,r&"
    # axis label styles
    base << "chxs=2,0000DD,9,-1,t,CCCCCC&"
    # axis tick mark styles
    base << "chxtc=0,10|1,10|2,-600&"    
    # axis names
    #base << "chl=Temperature|Time&"
    # axis ranges
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"  
    # axis labels
    base << "chxl=0:|#{time_labels.join('|')}|2:|min|max|mean|&"
    # axis label positions
    base << "chxp=2,#{summary.join(',')}&"
    # range for scaling data
    #base << "chds=#{min},#{max}&"
    # data
    base << "chd=t:#{temp.join(',')}"

    return base
  end
  
  def date_to_bin(date)  
      diff = (date.min>30) ? 60-date.min : 30-date.min
      d = date + diff.minutes
      min = (d.min<10) ? "0#{d.min}" : d.min.to_s
      hour = (d.hour>12) ? d.hour-12 : d.hour
      hour = 12 if hour == 0
      hour = (hour<10) ? "0#{hour}" : hour.to_s
      m = d.strftime("%p").downcase
      return "#{hour}:#{min}#{m}"
  end
  
  # Bin sensor data to closest 30 minutes. The first data point is thrown away,
  # as the temps contribute to the first 30 min bin.
  # 
  def descretize_sensor_data(sensors)
    labels = get_full_day_labels()
    bins = Array.new(labels.length) {|i| {:label=>labels[i],:temp=>0.0,:count=>0} }
    return bins if sensors.empty?
    # process sensor data
    sensors.each do |s|
      key = date_to_bin(s.created_at)
      # locate record
      record = bins.find {|r| r[:label]==key}
      raise "could not locate label for key #{key}, this should not happen!" if record.nil?
      record[:temp] += s.temp
      record[:count] += 1
    end    
    return bins
  end
  
  #
  # graph of sensor data
  #
  def make_day_sensors_graph_img_url(sensors, name, bom=nil)
    temp_union = []
    datasets = {}
    # process sensor data (if provided)
    if !sensors.nil? and !sensors.empty?
      sensors.keys.each do |station|
        bins = descretize_sensor_data(sensors[station])
        datasets[station] = []
        bins.each do |record| 
          if record[:count] > 0
            t = record[:temp] / record[:count].to_f
            temp_union << t
            datasets[station] << t
          else 
            datasets[station] << '_'
          end
        end
      end
    end    
    # process bom data (if provided)

    if !bom.nil? and !bom.empty?
      datasets["BoM"] = []
      bom.each do |rec| 
        if rec[0].nil?
          datasets["BoM"] << '_'
        else      
          datasets["BoM"] << rec[0].to_f
          temp_union << rec[0].to_f
        end
      end
      (48-datasets["BoM"].length).times { datasets["BoM"] << "_"}
    end

    min, max = temp_union.min, temp_union.max
    range = max-min
    num_series = datasets.keys.length
    time_labels = get_time_labels

    
    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=#{html_colors(num_series).join(',')}&"
    # graph title
    base << "chtt=Sensor Temperatures: #{name}&"
    # graph type
    base << "cht=lc&"
    # visible axes
    base << "chxt=x,y&"
    # axis ranges
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"
    # range for scaling data
    base << "chds=#{min},#{max}&"
    # axis labels
    base << "chxl=0:|#{time_labels.join('|')}&"
    # axis label positions
    #base << "chxp=0,#{display_time_labels.join(',')}&"
    # data legend
    base << "chdl=#{datasets.keys.join('|')}&"
    # data
    serieses = []
    datasets.keys.each {|key| serieses << datasets[key].join(',') }
    base << "chd=t:#{serieses.join('|')}"

    return base  
  end
  
  
  #
  # get a list of html colors
  #
  def html_colors(total)
    all_colors = ["FF0000", "00FF00", "0000FF", "00FFFF", "FF00FF", "FFFF00", "000000"]
    #return [] if total > all_colors.length
    return Array.new(total){|i| all_colors[i]}
  end
    
  #
  # labels for 24 hours
  #
  def get_full_day_labels()
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

  #
  # labels for 1 day time graphs
  #
  def get_time_labels
    return ["12:00am", "03:00am", "06:00am", "09:00am", "12:00pm", "03:00pm", "06:00pm", "09:00pm", "12:00am"]
  end  
  
  
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
  
  
  
  
  #
  # a number of contigious days concat together in a single series
  # sensors[:station][Sensor]
  # bom [day][records]
  #  
  def make_multi_day_sequence_with_sensor_graph_img_url(sensors, bom, name)
  
    temp_union = []
    datasets = {}
    # process sensor data (if provided)
    if !sensors.nil? and !sensors.empty?
      sensors.keys.each do |station|
        bins = descretize_sensor_data(sensors[station])
        datasets[station] = []
        bins.each do |record| 
          if record[:count] > 0
            t = record[:temp] / record[:count].to_f
            temp_union << t
            datasets[station] << t
          else 
            datasets[station] << '_'
          end
        end
      end
    end  
    # sort by full date
    keys = bom.keys
    keys.sort!{|x,y| bom[x][0][2].to_i<=>bom[y][0][2].to_i}      
    # bom
    datasets["BOM"] = []
    
    # create temp arrays and a union of all temps
    temps = {}
    bom.keys.each do |key|
      temps[key] = []
      bom[key].each do |v|
        if v[0].nil?
          temps[key] << '_'
        else
          temps[key] << v[0].to_f
          temp_union << v[0].to_f
        end

      end      
    end
    # create temp summary values
    min, max = temp_union.min, temp_union.max
    range = max-min
    
    #block out oldest day
    (48-temps[keys.first].length).times { temps[keys.first].unshift("_")}
    # block out today
    (48-temps[keys.last].length).times { temps[keys.last] << "_" }
    # labels (really rough, may not be accurate)
    time_labels = ["12:00am", "12:00pm", "12:00am", "12:00pm", "12:00am", "12:00pm", "12:00am", "12:00pm"]
    num_series = datasets.keys.length
    
    #build master BOM list
    keys.each { |key| datasets["BOM"] << temps[key] }
    
    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=#{html_colors(num_series).join(',')}&"
    # graph title
    base << "chtt=Sensor Temperatures: #{name}&"
    # graph type
    base << "cht=lc&"
    # visible axes
    base << "chxt=x,y&"
    # axis ranges
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"
    # range for scaling data
    base << "chds=#{min},#{max}&"
    # axis labels
    base << "chxl=0:|#{time_labels.join('|')}&"
    # data legend
    base << "chdl=#{datasets.keys.join('|')}&"
    # data
    serieses = []
    datasets.keys.each {|key| serieses << datasets[key].join(',') }
    base << "chd=t:#{serieses.join('|')}"

    return base     
        
    return base  
  end
end
