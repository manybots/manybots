# Configure Manybots Google Calendar OAuth clients

ManybotsGooglecalendar.setup do |config|
  # Google OAuth App Id
  config.google_app_id = '929393863741.apps.googleusercontent.com'
  
  # Google OAuth App Secret
  config.google_app_secret = 'KckScsk5fXE2G6HN64t98DZb'
  
  # App nickname
  config.nickname = 'manybots-googlecalendar'
end

app = ClientApplication.find_or_initialize_by_nickname ManybotsGooglecalendar.nickname
if app.new_record?
  app.app_type = "Observer"
  app.name = "Google Calendar Observer"
  app.description = "Import your events from Google Calendar"
  app.url = ManybotsServer.url + '/manybots-googlecalendar'
  app.app_icon_url = "/assets/manybots-googlecalendar/icon.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Productivity"
  app.is_public = true
  app.save
end
ManybotsGooglecalendar.app = app