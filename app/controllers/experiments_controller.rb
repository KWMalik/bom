require 'json'
require 'open-uri'

class ExperimentsController < ApplicationController


  
  # display today's temp as a graph
  def temp1
    # default to melbourne
    params[:station_id] = "2" if params[:station_id].nil?
    @station = Station.find(:first, :conditions=>['id=?', params[:station_id]])
    @stations = Station.find(:all, :order=>"name")        
    
    doc = download_and_parse_json(@station.url)
    @temp_data = get_today_data(doc)
    @summary = summary_for_day_temp_data(@temp_data)
  end
  

  
  # recent days  
  def temp2
    # default to melbourne
    params[:station_id] = "2" if params[:station_id].nil?
    @station = Station.find(:first, :conditions=>['id=?', params[:station_id]])
    @stations = Station.find(:all, :order=>"name")  
  
    doc = download_and_parse_json(@station.url)
    @temp_data = get_all_data_by_day(doc)
  end
  
  
  def temp3
    if !params[:name].nil? and !params[:temp].nil?
      # do manually instead of the rails way
      @sensor = Sensor.new(:name=>params[:name],:temp=>params[:temp])
      if @sensor.save
        flash[:notice] = "Sensor name=#{@sensor.name} temp=#{@sensor.temp} was saved successfully."
      else
        flash[:notice] = "Unable to save sensor data, perhaps it was poorly defined."
      end
    end
  end
  



  def temp4    
    #load sensor data
    @results_today = get_all_local_sensors_by_date(Date.today, Date.today+1)
    @results_yesterday = get_all_local_sensors_by_date(Date.today-1, Date.today)
    # load bom data
    doc = download_and_parse_json("http://www.bom.gov.au/fwo/IDV60801/IDV60801.94868.json")
    @bom_today = get_today_data(doc)
    @bom_yesterday = get_yesterday_data(doc)
  end
  
  
  def temp5
    @average = Sensor.average(:temp, :group=>"name", :order=>"name")
    @count = Sensor.count(:temp, :group=>"name", :order=>"name")
    @min = Sensor.minimum(:temp, :group=>"name", :order=>"name")
    @max = Sensor.maximum(:temp, :group=>"name", :order=>"name")
    
  end
  
  
  
  

  private
  
  
  # timezone set to melb, active record will do the magic for us i believe    
  # http://stackoverflow.com/questions/636553/how-to-properly-convert-or-query-date-range-for-rails-mysql-datetime-column
  # http://stackoverflow.com/questions/1262825/why-does-this-rails-query-behave-differently-depending-on-timezone  
  def get_all_local_sensors_by_date(start_date, end_date)
    names = Sensor.find(:all, :conditions=>["created_at between ? and ?", start_date.to_time.utc, end_date.to_time.utc], :group=>"name");
    results = {}
    names.each do |s|
      results[s.name] =  Sensor.find(:all, :conditions=>["created_at between ? and ? AND name=?", start_date.to_time.utc, end_date.to_time.utc, s.name], :order=>"created_at");
    end
    return results
  end

  
  def download_and_parse_json(url)
    buffer = open(url, "UserAgent"=>"Ruby").read
    doc = JSON.parse(buffer)
    return doc
  end
  

  
  
  # see: http://www.bom.gov.au/catalogue/observations/about-weather-observations.shtml
    
  def get_header(doc)
    doc["observations"]["header"]
  end
  
  def get_data(doc)
    doc["observations"]["data"]
  end
  
  def get_temp(record)
    return record["air_temp"]
  end
  
  def get_date(record)
    return record["local_date_time"]
  end
  
  def get_date_full(record)
    return record["local_date_time_full"]
  end
  

  
  #
  # temp data by day
  # in: parsed json doc
  # out: data[day][i][temp, day/time]
  #
  def get_all_data_by_day(doc)
    data = get_data(doc)
    map = {}
    data.each do |record|
      date = get_date(record)
      full_date = get_date_full(record)
      day = date.split('/')[0]
      if map[day].nil? then map[day] = [] end
      map[day] << [get_temp(record), date, full_date]
    end
    map.keys.each {|key| map[key] = map[key].reverse}
    return map
  end
  
  #
  # just todays data 
  # in: parsed json doc
  # out: data[i][temp, day/time]
  #
  def get_today_data(doc)
    data = get_data(doc)
    rs = []
    data.each do |record|
      date = get_date(record)
      day = date.split('/')[0]
      next if day.to_i != Date.today.day
      rs << [get_temp(record), date]
    end
    return rs.reverse 
  end
  
  
  #
  # just yesterdays data 
  # in: parsed json doc
  # out: data[i][temp, day/time]
  #
  def get_yesterday_data(doc)
    data = get_data(doc)
    rs = []
    data.each do |record|
      date = get_date(record)
      day = date.split('/')[0]
      next if day.to_i != (Date.today.day-1)
      rs << [get_temp(record), date]
    end
    return rs.reverse 
  end  

  #
  # make a summary hash for a days temp data
  # in: data[i][temp, day/time]
  # out: summary[key][value]
  #
  def summary_for_day_temp_data(data)
    summary = {}
    # raw temp data
    temp = []
    data.each {|r| next if r[0].nil?;temp << r[0].to_f}
    
    summary["total"] = data.length
    summary["min"] = temp.min
    summary["max"] = temp.max
    summary["mean"] = temp.sum/temp.length.to_f
    summary["start_time"] = data.first[1].split('/')[1]
    summary["end_time"] = data.last[1].split('/')[1]
    summary["day"] = data.first[1].split('/')[0]
    summary["last_time"] = data.last[1].split('/')[1]
    summary["last_temp"] = data.last[0]
    
    return summary
  end

end
