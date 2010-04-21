
class ExperimentsController < ApplicationController

  # display today's temp as a graph
  def temp1
    flash[:notice] = 'Sorry, the requested experiment has ended.'
    redirect_to(root_url)
  end
 
  # recent days  
  def temp2
    flash[:notice] = 'Sorry, the requested experiment has ended.'
    redirect_to(root_url)
  end
  
  # reception point for local sensor data
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
  
  # graph local sensor data
  def temp4    
    flash[:notice] = 'Sorry, the requested experiment has ended.'
    redirect_to(root_url)  
  end
  
  # summarize local stations
  def temp5
    flash[:notice] = 'Sorry, the requested experiment has ended.'
    redirect_to(root_url)
  end
  
  # review a site
  def temp6
    flash[:notice] = 'Sorry, the requested experiment has ended.'
    redirect_to(root_url)
  end
  
  
end
