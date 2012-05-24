# Configure Manybots Github OAuth clients

ManybotsGithub.setup do |config|
  # Github OAuth App Id
  config.github_app_id = 'bfe5dee5f0264019d927'
  
  # Github OAuth App Secret
  config.github_app_secret = 'ee411a1f85022c3dcd5edc6aa4b6f380d68637ee'
  
  # App nickname
  config.nickname = 'manybots-github'
end

app = ClientApplication.find_or_initialize_by_nickname ManybotsGithub.nickname
if app.new_record?
  app.app_type = "Observer"
  app.name = "Github Observer"
  app.description = "Import your commits and pushes from Github"
  app.url = ManybotsServer.url + '/manybots-github'
  app.app_icon_url = "/assets/manybots-github/icon.png"
  app.developer_name = "Manybots"
  app.developer_url = "https://www.manybots.com"
  app.category = "Productivity"
  app.is_public = true
  app.save
end
ManybotsGithub.app = app