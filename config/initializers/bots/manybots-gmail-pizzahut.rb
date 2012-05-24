# Configure the Manybots Gmail Pizzahut app

ManybotsGmailPizzahut.setup do |config|
  # App nickname
  config.nickname = 'manybots-gmail-pizzahut'
end

app = ClientApplication.find_or_initialize_by_nickname ManybotsGmailPizzahut.nickname
if app.new_record?
  app.app_type = "Agent"
  app.name = "Pizzahut PT Agent"
  app.description = "Convert order confirmation emails from Pizzahut PT into real activities."
  app.url = ManybotsServer.url + '/manybots-gmail-pizzahut'
  app.app_icon_url = "/assets/manybots-gmail-pizzahut/icon.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Lifestyle"
  app.is_public = true
  app.save
end
ManybotsGmailPizzahut.app = app
