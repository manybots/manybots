# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ManybotsLocal::Application.initialize!

# for gravatar
require 'digest/md5'

# activity filters
require 'activity_filter'
