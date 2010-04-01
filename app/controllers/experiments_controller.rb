require 'json'
require 'open-uri'

class ExperimentsController < ApplicationController


  
  # display today's temp as a graph
  def temp1
    @jsonurl = "http://www.bom.gov.au/fwo/IDV60801/IDV60801.94868.json"
    buffer = open(@jsonurl, "UserAgent" => "Ruby").read    
    @document = JSON.parse(buffer)
    @temp_data = get_today_data(@document)
  end

  private
  
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

end
