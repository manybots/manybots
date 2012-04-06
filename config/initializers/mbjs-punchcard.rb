app = ClientApplication.find_or_initialize_by_nickname 'mbjs-punchcard'
if app.new_record?
  app.app_type = "Visualization"
  app.name = "Punch Card"
  app.description = "See the time distribution of your activities."
  app.url = ManybotsServer.url + '/mbjs-punchcard/'
  app.screenshot = "#{app.url}/screenshot.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Productivity"
  app.is_public = true
  app.is_trusted = true
  app.save
end