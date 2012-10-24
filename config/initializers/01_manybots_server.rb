module Manybots

  class Server
  
    attr_accessor :server_name, :schema_url, :host, :url, :icon_url, :remote_language_parsing
  
    def initialize
      raw_config = File.read(Rails.root.to_s + "/config/manybots.yml")
      app_config = YAML.load(raw_config)[Rails.env].symbolize_keys
      @server_name = app_config[:server_name]
      @schema_url = app_config[:schema_url]
      @host = app_config[:host]
      @uri_date = app_config[:uri_date]
      @url = app_config[:url]
      @remote_language_parsing = app_config[:remote_language_parsing] || false
      @icon_url = @url + '/icon.png'
    end
    
    def queue
      @q ||= Queue.new
    end
    
    class Queue
      
      def add_schedule(schedule_name, options)
        Resque.set_schedule(schedule_name, options)
      end
      
      alias :set_schedule :add_schedule
      
      def remove_schedule(schedule_name)
        Resque.remove_schedule schedule_name
      end

      def get_schedules
        Resque.get_schedules
      end
      alias :schedules :get_schedules
      
      def enqueue(class_name, *args)
        Resque.enqueue(class_name, *args)
      end
      alias :add :enqueue
      
      def enqueue_at(when_is, class_name, *args)
        Resque.enqueue_at(when_is, class_name, *args)
      end

      def enqueue_in(when_is, class_name, *args)
        Resque.enqueue_in(when_is, class_name, *args)
      end
      
    end
  
  end

end

ManybotsServer = Manybots::Server.new