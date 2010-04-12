module ExperimentsHelper

  # see: http://code.google.com/apis/chart/docs/gallery/line_charts.html
  
  
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
  # just the labels to show  
  #
  def get_display_time_labels
    return ["12:00am","12:00pm","11:30pm"]
  end
  
  
  
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
    # labels
    time_labels = get_full_day_labels
    display_time_labels = get_display_time_labels 
    
    #build master temp list
    all_temps = []
    keys.each do |key|
      all_temps += temps[key]
    end

    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=00FF00,0000FF,FF0000,000000&"
    # graph title
    base << "chtt=Melbourne Temperatures&"
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
    base << "chxl=2:|min|mean|max|&"
    # axis label positions (!!!not working for axis 0!!!) => 0,#{display_time_labels.join(',')}|
    base << "chxp=2,#{summary.join(',')}&"
    base << "chd=t:#{all_temps.join(',')}"
        
    return base    
  end
  
  # 
  # graph of all recent days temperatures
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
    time_labels = get_full_day_labels
    display_time_labels = get_display_time_labels 


    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=00FF00,0000FF,FF0000,000000&"
    # graph title
    base << "chtt=Melbourne Temperatures&"
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
    base << "chxl=2:|min|mean|max|&"
    # axis label positions (!!!not working for axis 0!!!) => 0,#{display_time_labels.join(',')}|
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
  # graph of today's temperature (server time today)
  #
  def make_day_temp_graph_img_url(data)
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
    time_labels = get_full_day_labels
    display_time_labels = get_display_time_labels
    
    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=000000&"
    # graph title
    base << "chtt=Melbourne Temperature&"
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
    # axis label positions (!!!not working for axis 0!!!) => 0,#{display_time_labels.join(',')}|
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
    # SENSOR
    union = []
    display = []
    
    if sensors.nil? or sensors.empty?
      (48-display.length).times { display << "_"}
    else
      bins = descretize_sensor_data(sensors)
      bins.each do |record| 
        if record[:count] > 0
          t = record[:temp] / record[:count].to_f
          union << t
          display << t
        else 
          display << '_'
        end
      end
      station = sensors.first.name
    end
    
    # BOM
    bom_data = []
    if !bom.nil?
      bom.each do |rec| 
        if rec[0].nil?
          temp << '_'
        else      
          bom_data << rec[0].to_f
          union << rec[0].to_f
        end
      end
    end
    # block out today
   (48-bom_data.length).times { bom_data << "_"}
    
    min, max, avg = union.min, union.max, union.sum/union.size.to_f
    range = max-min
    summary = [min, max, avg]
    
    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=000000,FF0000&"
    # graph title
    base << "chtt=Sensor Temperatures: #{name}&"
    # graph type
    base << "cht=lc&"
    # visible axes
#    base << "chxt=x,y,r&"
    base << "chxt=x,y&"
    # axis label styles
#    base << "chxs=2,0000DD,9,-1,t,CCCCCC&"
    # axis tick mark styles
    #base << "chxtc=0,10|1,10|2,-600&"    
    # axis names
    #base << "chl=Temperature|Time&"
    # axis ranges
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"  
    # axis labels
#    base << "chxl=2:|min|max|mean|&"
    # axis label positions (!!!not working for axis 0!!!) => 0,#{display_time_labels.join(',')}|
#    base << "chxp=2,#{summary.join(',')}&"
    # range for scaling data
    base << "chds=#{min},#{max}&"
    # data legend
    base << "chdl=Local(#{station})|Bom&"
    # data
    base << "chd=t:#{display.join(',')}|#{bom_data.join(',')}"

    return base  
  end
  
  
  
end
