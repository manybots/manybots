if Rails.env.development?
  require 'active_record/connection_adapters/sqlite3_adapter'

  class ActiveRecord::ConnectionAdapters::SQLite3Adapter
    def initialize(db, logger, config)
      super
      db.create_function('regexp', 2) do |func, pattern, expression|
        regexp = Regexp.new(pattern.to_s, Regexp::IGNORECASE)
        if expression.to_s.match(regexp)
          func.result = 1
        else
          func.result = 0
        end
      end
    end
  end
end