module ExperimentsHelper

  # see: http://code.google.com/apis/chart/docs/gallery/line_charts.html
  
  
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
        temps[key] << v[0].to_f
        temps_union << v[0].to_f
      end      
    end
    # create temp summary values
    min, max, avg = temps_union.min, temps_union.max, (temps_union.sum/temps_union.size.to_f)
    range = max-min
    summary = [min, avg, max]
    # scale
    temps.keys.each do |key|
      temps[key].each_with_index do |v,i|
        temps[key][i] = ((v-min)/range)*100.0
      end 
    end
    summary.each_with_index {|v,i| summary[i] = ((v-min)/range)*100.0}
    
    #
    # todo, read: http://code.google.com/apis/chart/docs/data_formats.html
    # set ranges using chds
    #
    
    
    base = "http://chart.apis.google.com/chart?"
    base << "chs=600x240&"
    base << "chco=0000FF&"
    base << "chtt=Melbourne Temperature&"
    base << "cht=lc&"
    base << "chxt=x,y,r&"
    base << "chxs=2,0000DD,9,-1,t,FF0000&"
    base << "chxtc=0,10|1,10|2,-600&"
    base << "chl=Temperature|Time&"
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"    
    base << "chxl=2:|min|mean|max|&" 
    base << "chxp=2,#{summary.join(',')}&"
    
    #test with just last two days (not today)
    base << "chco=00FF00,0000FF&"
    base << "chdl=#{temps.keys[-3]}|#{temps.keys[-2]}&"
    base << "chd=t:#{temps[temps.keys[-3]].join(',')}|#{temps[temps.keys[-2]].join(',')}"
    
    #temps.keys.each_with_index do |key,i|
    #  next if i>1
    #  base << temps[key].join(',')
    #  # base << "|" if i < temps.length-1
    #  base << "|" if i<=0
    #end
        
    return base
  end
  
  
  
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
  
  def get_display_time_labels
    return ["12:00am","12:00pm","11:30pm"]
  end
  
  #
  # graph of today's temperature (server time today)
  #
  def make_day_temp_graph_img_url(data)
    # array of temp data
    temp = []
    data.each {|rec| temp << rec[0].to_f}
    # summary data
    min, max, avg = temp.min, temp.max, temp.sum/temp.size.to_f
    range = max-min
    summary = [min, max, avg]    
    # scale manually
    temp.each_with_index {|v,i| temp[i] = ((v-min)/range)*100.0}
    summary.each_with_index {|v,i| summary[i] = ((v-min)/range)*100.0}
    
    # block out the remainder of the temps for the day as nulls
    (48-temp.length).times { temp << "_"}
    time_labels = get_full_day_labels
    display_time_labels = get_display_time_labels
    
    base = "http://chart.apis.google.com/chart?"
    # graph size
    base << "chs=600x240&"
    # series colors
    base << "chco=0000FF&"
    # graph title
    base << "chtt=Melbourne Temperature&"
    # graph type
    base << "cht=lc&"
    # visible axes
    base << "chxt=x,y,r&"
    # axis label styles
    base << "chxs=2,0000DD,9,-1,t,FF0000&"
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

end
