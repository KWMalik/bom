class Sensor < ActiveRecord::Base


  validates_presence_of :name, :message=>"name must be provided"
  validates_length_of :name, :maximum=>256, :message=>"length of name must be >=3 <=256"
  
  validates_presence_of :temp, :message=>"temp must be provided"
  validates_numericality_of :temp, :message=>"temp must be numeric"
  
end
