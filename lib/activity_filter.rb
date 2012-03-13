AVAILABLE_FILTERS = [
  :verbs, :actors, :generators, :targets, :objects, :providers, :tags, :target_values, 
  :start_date, :end_date, :selected_month, :selected_year
]

class ActivityFilter
  attr_reader AVAILABLE_FILTERS.join
  
  def initialize(filtro)
    unless filtro.nil?
      for af in AVAILABLE_FILTERS.collect(&:to_s)
        if [:start_date.to_s, :end_date.to_s].include? af
          if filtro[af].present? and filtro[af].class.to_s == "Time"
            valor = filtro[af].beginning_of_day_in_zone
          else
            valor = filtro[af].nil? ? nil: Date.civil(filtro[af][:year].to_i,filtro[af][:month].to_i,filtro[af][:day].to_i).beginning_of_day_in_zone
          end
        else
          valor = filtro[af].nil? ? nil : filtro[af].split(',').to_a
        end
        instance_variable_set("@#{af}", valor)
      end
    else
      @verbs, @actors, @generators, @targets, @objects, @providers, @tags, @target_values,
        @start_date, @end_date, @selected_month, @selected_year = nil
    end
  end
  
  
  def all_options
    { 
      :verbs => @verbs,
      :actors => @actors,
      :generators => @generators,
      :targets => @targets,
      :target_values => @target_values,
      :objects => @objects,
      :providers => @providers,
      :tags => @tags,
      :start_date => @start_date,
      :end_date => @end_date,
      :selected_month => @selected_month,
      :selected_year => @selected_year
    }
  end
  
  def options
    new_options = {}
    self.all_options.to_a.each do |option|
      if option.last.is_a? Array
        new_options[option.first] = option.last.join(', ')
      else
        new_options[option.first] = option.last unless option.last.nil?
      end
    end
    new_options
  end
  
  def options_to_params
    new_options = options
    [:start_date, :end_date].each do |date|
      if new_options[date].present?
        blah = {}
        blah[:year] = options[date].to_date.year
        blah[:month] = options[date].to_date.month
        blah[:day] = options[date].to_date.day
        new_options[date] = blah
      end
    end
    new_options
  end

end