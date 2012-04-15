source 'http://rubygems.org'

gem 'rails', '3.2.3'
gem 'thin'

group :development, :test do
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"  
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end

# Manybots dependencies
gem 'jquery-rails'
gem 'rails_autolink'
gem 'resque', :require => "resque/server", :git => "http://github.com/webcracy/resque.git"
gem 'resque-scheduler', ">= 2.0.0.e"
gem 'rest-client', :require => 'rest_client'
gem 'sanitize'
gem 'chronic'
gem 'httparty'
gem 'devise', '1.5.3'
gem 'oauth'
gem 'oauth-plugin', :git => "http://github.com/webcracy/oauth-plugin.git"
gem 'acts-as-taggable-on', '~> 2.2.2'
gem 'will_paginate', '3.0.3'
gem 'haml'
gem 'builder'
gem 'dynamic_form', :git => 'https://github.com/rails/dynamic_form.git'

#
# Manybots observers, visualizations and apps
#

gem 'manybots-gmail', '0.0.2', :git => 'git://github.com/manybots/manybots-gmail.git'
gem 'gmail', :git => 'git://github.com/webcracy/gmail.git'

gem 'manybots-github', git: 'git://github.com/manybots/manybots-github.git'

gem 'manybots-googlecalendar', :git => 'git://github.com/manybots/manybots-googlecalendar.git'
gem 'google-api-client', :require => 'google/api_client'

gem 'manybots-weather', :git => 'git://github.com/manybots/manybots-weather.git'

gem 'manybots-gardener', :git => 'git://github.com/manybots/manybots-gardener.git'

gem 'manybots-gmail-pizzahut', :path => '/Users/alex/code/manybots/dev/manybots-gmail-pizzahut'

gem 'manybots-instagram', path: '/Users/alex/code/manybots/dev/manybots-instagram'
gem 'instagram', :git => 'git://github.com/webcracy/instagram-ruby-gem.git'
