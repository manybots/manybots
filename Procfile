web: bundle exec thin start -p $PORT
worker: QUEUE=* bundle exec rake resque:work
scheduler: bundle exec rake resque:scheduler