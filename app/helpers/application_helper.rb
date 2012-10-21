module ApplicationHelper
  
  def current_tab?(current_controller, id=nil)
    result = ''
    if current_controller.is_a? Array
      current_controller.each do |pc|
        result = "active" if controller_name == pc.to_s
      end
    elsif current_controller.is_a? Hash
      result = "active" if 
        current_controller[:controller] == controller_name and
        current_controller[:action] == controller.action_name
    else 
      if controller_name == current_controller.to_s
        result = "active" 
      end
    end
    if id 
      if result == 'active' and id.to_s == params[:id].to_s
        result = 'active'
      else
        result = ''
      end
    end
    result
  end
  
  def current_welcome_tab?(current_tab)
    return "active" if controller_name == "welcome" and controller.action_name == current_tab.to_s
  end
  
  
  def gravatar_url_for(email, options = {})
    url_for("https://secure.gravatar.com/avatar/" + Digest::MD5.hexdigest(email))
  end
  
  def active_param?(filtro, valor, local_params)
    if !local_params[:filter].nil? and local_params[:filter][filtro.to_s] and (
        (local_params[:filter][filtro.to_s].is_a?(String) and local_params[:filter][filtro.to_s].split(',').include?(valor.to_s)) or
        (['end_date', 'start_date'].include? filtro.to_s)
        )
      klass = "filter selected yellow smaller"
    else 
      klass = 'filter gray smaller' 
    end
    klass << ' awesome' unless filtro.to_s == 'tags'
    if klass and filtro.to_s == 'target_values'
      klass = 'selected'
    end
    return klass
  end
  
  def params_trick(filtro, valor, local_params)
    unless local_params[:filter].nil? 
      if local_params[:filter][filtro.to_s].present? and local_params[:filter][filtro.to_s].is_a? String
        if local_params[:filter][filtro.to_s].to_s == valor.to_s
          return remove_filter(filtro, valor, local_params)
        end
      else
        if ['start_date', 'end_date'].include? filtro
          return remove_filter(filtro, valor, local_params)
        end
      end
      unless filtro == :order
        h = {}
        h.clear
        h.merge! local_params
        valor = h['filter'][filtro].to_s.split(',').push(valor).join(',') 
        return {:filter => local_params[:filter].merge({filtro => valor})}
      else 
        return {:filter => local_params[:filter].merge({filtro => valor})}
      end      
    else
      return {:filter => {"#{filtro}" => valor }}
    end
  end
  
  def remove_filter(filtro, valor, local_params)
    filters = {}
    filters.merge! local_params[:filter]
    if filters[filtro.to_s].is_a?(String)
      ids = filters[filtro.to_s].split(',').to_a
      if ids.is_a? Array and ids.size > 1
        ids.delete valor.to_s
        valor = ids.join(',') 
        return {:filter => local_params[:filter].merge({filtro => valor})}
      end
    end
    filters.delete(filtro.to_s)
    return {:filter => filters }
  end
  
  def name_only(uri)
    uri.to_s.split('/').last.to_s.gsub('-', ' ').titleize
  end
  
  def object_title_span(word)
    "<span class='object-title'>#{word}</span>"
  end
  
  def indexable_omnisearch_rel(search_type, result)
    return case search_type
    when 'apps', 'filters', 'bundles'
      result.name
    when 'activities'
      ''
    else
      result
    end
  end
end
