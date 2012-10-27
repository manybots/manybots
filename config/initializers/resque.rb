require 'resque_scheduler'
require 'resque/scheduler'
require 'resque-sliders'
require 'resque_scheduler/server'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]
Resque.redis.namespace = "resque:Manybots"

Resque::Scheduler.dynamic = true

## Uncomment and edit to add basic auth to the resque-server web interface
# Resque::Server.use(Rack::Auth::Basic) do |user, password|
#   user == "user" and password == "secret"
# end
