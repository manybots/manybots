# Configure Manybots Instagram OAuth client

ManybotsInstagram.setup do |config|
  # Instagram OAuth App Id
  config.instagram_app_id = '1c9f231946d6479faf27afb1507b89bb'
  
  # Instagram OAuth App Secret
  config.instagram_app_secret = '4a53caec0d3649e09b5213f3851fe46c'
  
  # App nickname
  config.nickname = 'manybots-instagram'
end

app = ClientApplication.find_or_initialize_by_nickname ManybotsInstagram.nickname
if app.new_record?
  app.app_type = "Observer"
  app.name = "Instagram Observer"
  app.description = "Import your pictures from Instagram"
  app.url = ManybotsServer.url + '/manybots-instagram'
  app.app_icon_url = ManybotsServer.url + "/assets/manybots-instagram/icon.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Lifestyle"
  app.is_public = true
  app.save
end
ManybotsInstagram.app = app
