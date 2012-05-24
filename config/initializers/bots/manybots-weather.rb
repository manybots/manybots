# Configure the Manybots Weather app

ManybotsWeather.setup do |config|
  # Yahoo App Id
  config.yahoo_app_id = 'g.ZtgNfV34EHNyNKQYSFjPdjl7LC8KIzLQqyK7Czh3ioCn0CWUVCcKONeI0YVFLF'  
  # App nickname
  config.nickname = 'manybots-weather'
end

app = ClientApplication.find_or_initialize_by_nickname ManybotsWeather.nickname
if app.new_record?
  app.app_type = "Observer"
  app.name = "Weather Observer"
  app.description = "Get notified on the Weather Conditions (uses Yahoo! Weather API)"
  app.url = ManybotsServer.url + '/manybots-weather'
  app.app_icon_url = "/assets/manybots-weather/icon.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Lifestyle"
  app.is_public = true
  app.save
end
ManybotsWeather.app = app
