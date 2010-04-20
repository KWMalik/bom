class HomeController < ApplicationController

  def index
    @stations = Station.find(:all, :order=>"name")
    # hack
    @offices = ["Australian Bureau of Meteorology"]
  end
  
  def about 
  
  end

end
