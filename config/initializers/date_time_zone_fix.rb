class ::Date
  
  def beginning_of_day_in_zone
    Time.zone.parse(self.to_s)
  end
  
  alias_method :at_beginning_of_day_in_zone, :beginning_of_day_in_zone
  alias_method :midnight_in_zone, :beginning_of_day_in_zone
  alias_method :at_midnight_in_zone, :beginning_of_day_in_zone

  def end_of_day_in_zone
    Time.zone.parse((self+1).to_s) - 1
  end
  
end

class ::Time
  
  def beginning_of_day_in_zone
    Time.zone.parse(self.to_s)
  end
  
  alias_method :at_beginning_of_day_in_zone, :beginning_of_day_in_zone
  alias_method :midnight_in_zone, :beginning_of_day_in_zone
  alias_method :at_midnight_in_zone, :beginning_of_day_in_zone

  def end_of_day_in_zone
    Time.zone.parse((self+1).to_s) - 1
  end
  
end