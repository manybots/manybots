# Configure the Manybots Gardener app

ManybotsGardener.setup do |config|
  # App nickname
  config.nickname = 'manybots-gardener'
end

app = ClientApplication.find_or_initialize_by_nickname ManybotsGardener.nickname
if app.new_record?
  app.app_type = "Agent"
  app.name = "Gardener Agent"
  app.description = "Get predictions and notifications of when to water your plants"
  app.url = ManybotsServer.url + '/manybots-gardener'
  app.app_icon_url = "/assets/manybots-gardener/icon.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Lifestyle"
  app.is_public = true
  app.save
end
ManybotsGardener.app = app
