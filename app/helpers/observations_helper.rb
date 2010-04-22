module ObservationsHelper

  def degrees(text)
    return text if !(text.kind_of? Float)
    return "#{text.to_f.round(1)}&deg;C"
  end
  
  def degrees_full(text)
    return text if !(text.kind_of? Float)
    return "#{text.to_f}&deg;C"
  end

  def site_link(name)
    # special case
    return link_to(name, localsites_path) if name.downcase == "office"
    # station
    Station.all.each do |station|    
      if station.name == name
        return link_to(name, official_path(:station_id=>station.id))
      end
    end
    # assume it is an office site
    return link_to(name, site_path(:name=>name))
  end

end
