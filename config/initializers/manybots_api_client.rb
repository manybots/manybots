# encoding: UTF-8
require 'json/add/core'
require 'httparty'

module Manybots
  
  class Client
    include HTTParty
    
    base_uri ManybotsServer.url
    
    def initialize(t)
      @auth_token = t
    end

    def activities(filters = {}, page = 1, per_page = 10)
      options = { 
        :query => {
          :auth_token => @auth_token,
          :filter => filters, 
          :page => page,
          :per_page => per_page
        }
      }
      self.class.get('/activities.json', options)
    end
    
    def notifications(filters = {}, page = 1, per_page = 10)
      options = { 
        :query => {
          :auth_token => @auth_token,
          :filter => filters, 
          :page => page,
          :per_page => per_page
        }
      }
      self.class.get('/notifications.json', options)
    end
    
            
    def create_activity(activity = {})
      options = {
        :body => {
          :auth_token => @auth_token,
          :version => '1.0',
          :activity => activity
        }
      }
      self.class.post('/activities.json', options)
    end
    
    def create_notification(activity = {})
      options = {
        :body => {
          :auth_token => @auth_token,
          :version => '1.0',
          :activity => activity
        }
      }
      self.class.post('/notifications.json', options)
    end
    
    
  end
end

