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
  
  #
  # graph of today's temperature (server time today)
  #
  def make_day_temp_graph_img_url(data)
    temp, time, timelabel = [], [], []
    data.each_with_index do |rec,i| 
      temp << rec[0].to_f
      timelabel << rec[1].split('/')[1]
      time << i
    end

    min, max, avg = temp.min, temp.max, temp.sum/temp.size.to_f
    range = max-min
    summary = [min, max, avg]    
    
    temp.each_with_index {|v,i| temp[i] = ((v-min)/range)*100.0}
    summary.each_with_index {|v,i| summary[i] = ((v-min)/range)*100.0}
    
    # block out the remainder of the temps for the day as nulls
    (48-temp.length).times { temp << "_"}
    time_labels = get_full_day_labels
    
    base = "http://chart.apis.google.com/chart?"
    base << "chs=600x240&"
    base << "chco=0000FF&"
    base << "chtt=Melbourne Temperature&"
    base << "cht=lc&"
    base << "chxt=x,y,r&"
    base << "chxs=2,0000DD,9,-1,t,FF0000&"
    base << "chxtc=0,10|1,10|2,-600&"    
    #base << "chl=Temperature|Time&"
    base << "chxr=1,#{min},#{max},#{(range)/10.0}&"    
    base << "chxl=0:|#{time_labels.join('|')}|2:|min|max|mean|&"
    
    #base << "chxl=2:|min|avg|max|&" 
    base << "chxp=2,#{summary.join(',')}&"
    base << "chd=t:#{temp.join(',')}"
        
    return base
  end

end
