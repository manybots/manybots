class SearchController < ApplicationController
  
  before_filter :authenticate_user!
  
  def create
    query = params[:q]
    
    do_normal_search(query)
    do_date_search(query)
    if ManybotsServer.remote_language_parsing
      begin
        do_remote_language_parsing(query)
      rescue => e
        logger.error e
      end
    end
    render 'index', :layout => !request.xhr?
  end
  
  def everything
    @query = CGI.unescape params[:query] || ''
    do_regexp_or_like(@query)
    @activities = current_user.activities.where("clean_title #{@func} ?", @regexp).timeline.limit(10)
    respond_to do |format|
      format.html {}
      format.json {render :json => {data: {items: @activities}}.to_json} 
    end
  end
  
  private
  
    def do_regexp_or_like(query)
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase.to_sym
      case adapter_type
      when :mysql, :mysql2
        @func = "LIKE"
        @regexp = "#{query}%"
      when :sqlite
        @func = "REGEXP"
        @regexp = "\\b#{query}"
      when :postgresql, :pg2
        @func = "~*"
        @regexp = "\\m#{query}"
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
    end
    
    def do_date_search(query)
      date = Chronic.parse(query)
      @search_date = Aggregation.new_date(date) if date
    end
    
    def do_normal_search(query)
      @query = "%#{query}%"
      do_regexp_or_like(query)
      @results = current_user.aggregations.where("name #{@func} ? ", @regexp).order('total DESC')
    end
    
    def do_remote_language_parsing(query)
      if query.split(' ').length >= 2 and @results.empty?
        # get the url that we need to post to
        uri = URI.parse("https://thebotbot.herokuapp.com")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Post.new("/parse")
        req['Content-Type'] = 'application/json'
        req.body = {sentence: query}.to_json
        response = http.request(req)
        begin
          body = JSON.load(response.body)
        rescue => e
          logger.error e.inspect
          return nil
        end
        filters = []
        filters.push body if body
        if filters.any?
          @results = Aggregation.find_aggregations_for_user_and_params(current_user, filters)
        else
          @results = []
        end
      end
    end
end
