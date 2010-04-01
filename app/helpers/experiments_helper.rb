module ExperimentsHelper

  # see: http://code.google.com/apis/chart/docs/gallery/line_charts.html
  
  
  def make_multiday_temp_graph_img_url(data)
    # get temp
    temps = {}
    temps_union = []
    data.keys.each do |key|
      temps[key] = []
      data[key].each |v|
        temps[key] << v[0].to_f
      end      
      temps_union += data[key]
    end
    # top level summary
    min, max, avg = temps_union.min, temps_union.max, temps_union.sum/temps_union.size.to_f
    range = max-min
    summary = [min, max, avg]
    #scale
    temps.keys.each do |key|
      temps[key].each_with_index |v,i|
        temps[key][i] = ((v-min)/range)*100.0
      end 
    end
    summary.each_with_index {|v,i| summary[i] = ((v-min)/range)*100.0}
    
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
    base << "chxl=0:|#{timelabel.join('|')}|2:|min|max|avg|&"
    #base << "chxl=2:|min|avg|max|&" 
    base << "chxp=2,#{summary.join(',')}&"   
    #base << "chd=t:#{temp.join(',')}"
        
    return base
  end
  
  
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
    base << "chxl=0:|#{timelabel.join('|')}|2:|min|max|avg|&"
    #base << "chxl=2:|min|avg|max|&" 
    base << "chxp=2,#{summary.join(',')}&"   
    base << "chd=t:#{temp.join(',')}"
        
    return base
  end

end
