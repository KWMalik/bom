class Station < ActiveRecord::Base


  def self.default_station
    return Station.find_by_name("Melbourne")
  end

end
