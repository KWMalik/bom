class Sensor < ActiveRecord::Base


  validates_presence_of :name, :message=>"name must be provided"
  validates_presence_of :temp, :message=>"temp must be provided"
  
  # todo numeric, max length, etc
  
end
