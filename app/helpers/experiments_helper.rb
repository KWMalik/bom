module ExperimentsHelper


  # see: http://code.google.com/apis/chart/docs/making_charts.html
  # see: http://code.google.com/apis/chart/docs/gallery/line_charts.html
  def make_temp_graph_img_url(data)
    #return "http://chart.apis.google.com/chart?chs=250x100&chd=t:60,40&cht=p3&chl=Hello|World"
    
    temp, time, timelabel = [], [], []
    data.each_with_index do |rec,i| 
      temp << rec[0].to_i
      timelabel << rec[1].split('/')[1]      
      time << i
    end
    
    base = "http://chart.apis.google.com/chart?"
    base << "chs=640x240&"
    base << "chtt=Melbourne Temperature&"
    base << "cht=lc&"
    base << "chl=Temperature|Time&"
    base << "chxt=x,y&"
    #base << "chxl=0:|#{timelabel.join('|')}&"
    base << "chxr=1,0,50,5&"
    base << "chd=t:#{temp.join(',')}"
    
    return base
  end

end
