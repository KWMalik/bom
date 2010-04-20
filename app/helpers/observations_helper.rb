module ObservationsHelper

  def degrees(text)
    return "#{text.to_f.round(1)}&deg;C"
  end

end
