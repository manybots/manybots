# Configure Manybots Gmail OAuth clients
# works by default with 'anonymous' app id and secret

ManybotsGmail.setup do |config|
  # Gmail OAuth App Id
  # config.gmail_app_id = 'anonymous'
  
  # Gmail OAuth App Secret
  # config.gmail_app_secret = 'anonymous'
  
  # App nickname
  config.nickname = 'manybots-gmail'
end

app = ClientApplication.find_or_initialize_by_nickname ManybotsGmail.nickname
if app.new_record?
  app.app_type = "Observer"
  app.name = "Gmail Observer"
  app.description = "Import your emails from Gmail"
  app.url = ManybotsServer.url + '/manybots-gmail'
  app.app_icon_url = "/assets/manybots-gmail/icon.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Productivity"
  app.is_public = true
  app.save
end
ManybotsGmail.app = app