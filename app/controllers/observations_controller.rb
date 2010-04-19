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
  
  end
  
  def local
  
  end
  
  
  private
  
  # melb
  def default_station
    return Station.default_station.id
  end

end
