web: bundle exec thin start -p $PORT
scheduler: bundle exec rake resque:scheduler
workerwatcher: bundle exec kewatcher -m 8 -n 'resque:Manybots'
