
class Graph


  def init 
    @dataset = {}
  end

  
  # in: data[day][i][temp, day/time]
  def parse_from_bom(basic)

    
  end
  
  def parse_from_sensors(sensors)
  
  end
  
  
  
  
  def get_graph_url()
  
  end
  
  
  #
  # labels for 24 hours
  #
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

end
