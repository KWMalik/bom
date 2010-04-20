require 'json'
require 'open-uri'

class Bom

  attr_reader :url, :name, :document, :basic, :dataset


  def get_today
    day = Date.today.day
    @dataset[@name].keys.each do |d|
      return @dataset[@name][d] if d.day == day
    end
    return nil
  end
  
  def get_last_temp
    # cheat, use basic data representation so i don't need 
    # to figure out the time right now in label form    
    day = Date.today.day.to_s
    @basic.keys.each do |day_key|      
        return @basic[day_key].last[0].to_f if day_key == day
    end
    return nil
  end

  def load_temperatures(url, name)
    @name = name
    @url = url
    # download
    download_and_parse_json
    # basic parse into hash/arrays
    get_all_data_by_day
    # process into standard form
    standardize
  end
  
  # download and parse into JSON structure
  def download_and_parse_json
    buffer = open(@url, "UserAgent"=>"Ruby").read
    @document = JSON.parse(buffer)
  end
  
  # data[key][date][label, count, temp]
  def standardize
    @dataset = {}
    @dataset[@name] = {}
    # init
    @basic.keys.each do |day|
      date_s = @basic[day].first[2]
      date = bom_full_date_to_date(date_s)      
      @dataset[@name][date] = []
      Graph.times_full_day.each do |label|
        @dataset[@name][date] << {:label=>label,:count=>0,:temp=>0.0}
      end
    end
    # process temps
    @basic.keys.each do |day|
      date_s = @basic[day].first[2]
      date = bom_full_date_to_date(date_s) 
      @basic[day].each do |bom_record|
        # locate record
        time_key = bom_record[1].split('/')[1]
        record = @dataset[@name][date].find {|r| r[:label]==time_key}
        #raise "could not locate label for key #{time_key}, this should not happen!" if record.nil?
        next if record.nil?
        record[:count] = 1
        record[:temp] = bom_record[0].to_f
      end
    end
  end
  
  def bom_full_date_to_date(date_s)
    # just get the YYYYMMDD
    date_s = date_s[0..7]
    date = Date.strptime(date_s, '%Y%m%d')
    return date
  end
  
  # data[day][i][temp, date, full_date]
  def get_all_data_by_day
    data = get_data(@document)
    @basic = {}
    data.each do |record|
      date = get_date(record)
      full_date = get_date_full(record)
      day = date.split('/')[0]
      if @basic[day].nil? then @basic[day] = [] end
      @basic[day] << [get_temp(record), date, full_date]
    end
    # reverse all times
    @basic.keys.each {|key| @basic[key] = @basic[key].reverse}
  end
  
  
  # data formats
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

end
