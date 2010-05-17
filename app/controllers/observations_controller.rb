require 'net/http'
require 'uri'

class ObservationsController < ApplicationController

  # official observations
  def official
    # default to melbourne
    params[:station_id] = default_station if params[:station_id].nil?
    @station = Station.find(:first, :conditions=>['id=?', params[:station_id]])
    @stations = Station.find(:all, :order=>"name")        
    # load bom data
    @bom = Bom.new
    @bom.load_temperatures(@station.url, @station.name)
    # build graph data
    @graph = Graph.new
    @graph.add_dataset(@bom.dataset)
  end
  
  # office observations (average)
  def local
    # default to melbourne
    params[:station_id] = default_station if params[:station_id].nil?
    @station = Station.find(:first, :conditions=>['id=?', params[:station_id]])
    @stations = Station.find(:all, :order=>"name")       
    
    # local data
    @office = "Australian Bureau of Meteorology"
    @local = Local.new
    @local.load_last_4_days_dataset("Office")     
    # load bom data
    @bom = Bom.new
    @bom.load_temperatures(@station.url, @station.name)
    # build graph data
    @graph = Graph.new
    @graph.add_dataset(@bom.dataset)  
    @graph.add_dataset(@local.avg_dataset)
    
    # temp difference
    @bom_temp = @bom.get_last_temp
    @temp_difference = nil
    @temp_difference = @local.get_last_temp_avg - @bom_temp if !@bom_temp.nil?
  end
  
  # office observations (by site)
  def local_by_site
    # default to melbourne
    params[:station_id] = default_station if params[:station_id].nil?
    @station = Station.find(:first, :conditions=>['id=?', params[:station_id]])
    @stations = Station.find(:all, :order=>"name")       
    
    # local data
    @office = "Australian Bureau of Meteorology"
    @local = Local.new
    @local.load_last_4_days_dataset("Office")     
    # load bom data
    #@bom = Bom.new
    #@bom.load_temperatures(@station.url, @station.name)
    # build graph data
    @graph = Graph.new
    #@graph.add_dataset(@bom.dataset)  
    @graph.add_dataset(@local.dataset)
    
    # all sites for this office
    @tmp_local = Local.new
    @sites = Sensor.find(:all, :group=>"name", :order=>"name")
  end  
  
  # site summary
  def site
    # default to melbourne
    params[:station_id] = default_station if params[:station_id].nil?
    @station = Station.find(:first, :conditions=>['id=?', params[:station_id]])
    @stations = Station.find(:all, :order=>"name")  
    # site
    name = params[:name]
    # local data
    @office = "Australian Bureau of Meteorology"
    @local = Local.new
    @local.load_last_7_days_dataset(name)
    # build graph data
    @graph = Graph.new
    @graph.add_dataset(@local.dataset)
    # recent
    @recent_graph = Graph.new
    @recent_graph.add_dataset(@local.recent_dataset) 
  end


  # post to get a google chart
  # http://code.google.com/apis/chart/docs/post_requests.html
  def chart
    # assume all the parameters were pushed here, build a custom list
    post_params = {}
    params.keys.each do |key|
     next if key == 'action' or key == 'controller'
     post_params[key] = params[key]
    end
  
    # do a post to get the image data
    url = "http://chart.apis.google.com/chart"
    res = Net::HTTP.post_form(URI.parse(url), post_params)
    data = res.body
    
    # send image data 
    # http://api.rubyonrails.org/classes/ActionController/Streaming.html
    send_data(data, :type=>"image/png", :disposition => 'inline')    
  end

  
  private
  
  # melb
  def default_station
    return Station.default_station.id
  end

end
