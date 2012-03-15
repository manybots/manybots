web: bundle exec thin start -p $PORT
worker: bundle exec rake resque:work QUEUE=*
scheduler: bundle exec rake resque:scheduler
