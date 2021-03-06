class Local

  attr_reader :name, :resultset, :dataset, :avg_dataset, :recent_resultset, :recent_dataset

  # an entry point
  # load sensor data for the last 4 days in the standardized representation  
  def load_last_4_days_dataset(name)
    @name = name
    # retrieve from database
    load_all_local_sensors_by_date(Date.today-3, Date.today+1)
    # standardize
    standardize
    # calculate average for this office
    average_for_office
  end
  
  
  # an entry point
  # return sensor data for a given site (sensor name) for the last 7 days
  def load_last_7_days_dataset(name)
    @name = name
    # retrieve from database
    load_local_sensors_by_name_last_week(@name)
    # standardize
    standardize
    # calculate average for this office (to be consistent)
    average_for_office    
    # calculate the last ten minutes (for this site)
    last_10_minutes
  end  
  
  # summary for a site name
  def get_summary_for_site(name=@name)
    summary = {}    
    summary[:name] = name
    # total
    summary[:total] = Sensor.count(:all, :conditions=>['name=?',name])
    # first obs date
    rs = Sensor.find(:first, :conditions=>['name=?',name], :order=>"created_at")
    summary[:first_datetime] = (!rs.nil?) ? rs.created_at : ""
    # last obs date
    rs = Sensor.find(:first, :conditions=>['name=?',name], :order=>"created_at DESC")
    summary[:last_datetime] = (!rs.nil?) ? rs.created_at : ""
    # max
    rs = Sensor.maximum(:temp, :conditions=>['name=?',name])
    summary[:max] = rs
    # min
    rs = Sensor.minimum(:temp, :conditions=>['name=?',name])
    summary[:min] = rs
    # avg
    rs = Sensor.average(:temp, :conditions=>['name=?',name])
    summary[:mean] = rs.to_f
    
    return summary
  end

  
  # retrieve the lat average office temperature for today
  def get_last_temp_avg
    today = @avg_dataset[@name].keys.sort.last
    raise "Do not have data for today #{today}" if today != Date.today
    @avg_dataset[@name][today].reverse.each do |record|
      return record[:temp] if record[:count] > 0
    end
  end
  
  # retrieve the last temperature for a station for today
  def get_last_temp(name)
    today = @dataset[name].keys.sort.last
    #raise "Do not have data for today #{today}" 
    return "n/a" if today != Date.today
    @dataset[name][today].reverse.each do |record|
      return record[:temp] if record[:count] > 0
    end
  end  
  
  
  # the recent dataset
  def last_10_minutes
    @recent_dataset = {}
    @recent_dataset[@name] = {}
    @recent_dataset[@name][Date.today] = []
    
    # lazy, just re-query
    # TODO just pull out of the result set, they are sorted already 
    time = Date.today.to_time.utc
    @recent_resultset = Sensor.find(:all, 
      :conditions=>['created_at > ? and name=?', time.utc, @name], 
      :order=>"created_at DESC", 
      :limit=>10);
    @recent_resultset.reverse!
    @recent_resultset.each do |sensor|
      record = {}
      record[:label] = sensor.created_at.to_s
      record[:temp] = sensor.temp
      record[:count] = 1
      @recent_dataset[@name][Date.today] << record
    end
  end
  
  def average_for_office
    @avg_dataset = {}
    @avg_dataset[@name] = {}
    # collect
    @dataset.keys.each do |station|
      @dataset[station].keys.each do |date|
        # create as needed
        if @avg_dataset[@name][date].nil?
          labels = Graph.times_full_day
          @avg_dataset[@name][date] = Array.new(labels.length) {|i| {:label=>labels[i],:temp=>0.0,:count=>0,:sum=>0.0}}
        end
        # process records
        @dataset[station][date].each do |record|
          # update if data
          if record[:count] > 0
            # assume not sorted
            match = @avg_dataset[@name][date].find {|r| r[:label]==record[:label]}
            raise "could not locate label for key #{record[:label]}, this should not happen!" if match.nil?
            match[:sum] += record[:temp]
            match[:count] += 1
          end
        end
      end
    end
    # average
    @avg_dataset[@name].keys.each do |date|
      @avg_dataset[@name][date].each do |rec|
        rec[:temp] = ((rec[:count]>0) ? rec[:sum]/rec[:count] : 0.0)
      end
    end
  end
  
  
  # in: data[name][sensor's for a range of dates]
  # out: data[name][date][label, count, temp]
  def standardize
    @dataset = {}
    return dataset if @resultset.empty?
    # process sensors for each station
    @resultset.keys.each do |station|
      # group into days: assume 4 days for now
      days = descretize_sensor_data_by_day(@resultset[station])
      @dataset[station] = {}      
      # process days
      days.keys.each do |date|
        # squash into hours (ordered)
        @dataset[station][date] = descretize_sensor_data_by_half_hour(days[date])
      end
    end
  end

  # hour bins (label format that matches the BOM data)
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
  
  # in: data[sensors]
  # out: data[label,tmp,count]
  def descretize_sensor_data_by_half_hour(sensors)
    labels = Graph.times_full_day
    bins = Array.new(labels.length) {|i| {:label=>labels[i],:temp=>0.0,:count=>0,:sum=>0.0} }
    return bins if sensors.empty?
    # process sensor data
    sensors.each do |s|
      key = date_to_bin(s.created_at)
      # locate record
      record = bins.find {|r| r[:label]==key}
      raise "could not locate label for key #{key}, this should not happen!" if record.nil?
      record[:sum] += s.temp
      record[:count] += 1
    end    
    # calculate temperatures
    bins.each do |rec| 
      rec[:temp] = ((rec[:count]>0) ? rec[:sum]/rec[:count] : 0.0)
    end
    return bins
  end
  
  # assume active record is using local time zone for date stuff (seems it does)
  # in: data[sensors...]
  # out data[date][sensors...]
  def descretize_sensor_data_by_day(sensors)
    data = {}
    sensors.each do |s|
      key = s.created_at.to_date
      data[key] = [] if data[key].nil?      
      data[key] << s
    end
    return data
  end  
  
  # load all sensor data for all sites between the specified dates
  # timezone set to melb, active record will do the magic for us i believe
  # out: [name][sensors]
  def load_all_local_sensors_by_date(start_date, end_date)
    s_date = start_date.to_time.utc
    e_date = end_date.to_time.utc  
    names = Sensor.find(:all, 
      :conditions=>["created_at between ? and ?", s_date, e_date], 
      :group=>"name");
    @resultset = {}
    names.each do |s|
      @resultset[s.name] = Sensor.find(:all, 
        :conditions=>["created_at between ? and ? AND name=?", s_date, e_date, s.name], 
        :order=>"created_at");
    end
  end
  
  # load all sensor data by day for the last week for the given site name
  # out: [name][sensors]
  def load_local_sensors_by_name_last_week(name)
    s_date = (Date.today-6).to_time.utc
    e_date = (Date.today+1).to_time.utc  
    @resultset = {}
    @resultset[name] = Sensor.find(:all, 
      :conditions=>["created_at between ? and ? AND name=?", s_date, e_date, name], 
      :order=>"created_at");
  end
   
end
