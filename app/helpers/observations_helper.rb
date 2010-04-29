module ObservationsHelper

  def degrees(text)
    return text if !(text.kind_of? Float)
    return "#{text.to_f.round(1)}&deg;C"
  end
  
  def degrees_full(text)
    return text if !(text.kind_of? Float)
    return "#{text.to_f}&deg;C"
  end


  # TODO: do not query each time we display a link!!! 
  # actually, i think rails will cache the resultset in env=production
  def site_link(name)
    # special case
    return link_to(name, localsites_path) if name.downcase == "office"
    # station
    Station.all.each do |station|    
      if station.name == name
        return link_to(name, official_path(:station_id=>station.id))
      end
    end
    # check for a known sensor name
    Sensor.find(:all, :group=>"name").each do |sensor|
      if sensor.name == name
        return link_to(name, site_path(:name=>name))
      end
    end
    # assume nothing!
    return name
  end

end
