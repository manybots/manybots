class VisualizationApp
  
  def initialize(path)
    @path = path.split('./public').last.split('manybots.json').first
    
    begin
      @payload = JSON.load open(path)
    rescue => e
      raise "Error loading visualization at #{@path}: #{e}"
    end
  end
  
  def display
    @display ||= @payload['display']
  end
  
  def name
    @name ||= @payload['name']
  end
  
  def developer
    @developer ||= @payload['developer']
  end
  
  def nickname
    @nickname ||= @payload['nickname']
  end
  
  def category
    @category ||= @payload['category']
  end
  
  def description
    @description ||= @payload['description'].strip
  end
  
  def target_objects
    return case self.display['objects']
    when 'all'
      'all'
    else
      self.display['objects'].join(',') rescue('all')
    end
  end
  
  def load_app
    app = ClientApplication.find_or_initialize_by_nickname self.nickname
    if app.new_record?
      app.app_type = "Visualization"
      app.url = ManybotsServer.url + @path
      app.screenshot = "#{app.url}screenshot.png"
      app.app_icon_url = "#{app.url}icon.png"
    end
    app.name = self.name || app.nickname
    app.description = self.description
    
    app.in_menu = self.display['menu']
    app.in_library = self.display['library']
    app.target_objects = self.target_objects
    
    app.developer_name = self.developer['name']
    app.developer_url = self.developer['url']
    app.category = self.category
    app.save
    app
  end
  
  def self.load_all
    visualizations = Dir["./public/*/manybots.json"]
    visualizations.collect do |vis|
      visualization = self.new(vis)
      visualization.load_app
    end
  end

end # Visualization