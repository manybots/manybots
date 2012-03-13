require 'resque/tasks'
require 'resque_scheduler/tasks' 

task "resque:setup" => :environment do
  require 'resque'  
  require 'resque_scheduler'
  require 'resque/scheduler'


  Resque::Scheduler.dynamic = true
end
