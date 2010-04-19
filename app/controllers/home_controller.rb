class HomeController < ApplicationController

  def index
    @stations = Station.find(:all, :order=>"name")
  end
  
  def about 
  
  end

end
