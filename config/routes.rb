ManybotsLocal::Application.routes.draw do
    
  devise_for :users do
    get "/login" => "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy"
    get "/account" => "devise/registrations#edit"
    get "/account/password" => "dashboard#password"
    post "/account/update_password" => "dashboard#update_password"
  end


  mount ManybotsGmail::Engine => "/manybots-gmail"

  match "/dashboard/day/:year/:month/:day", :to => "dashboard#day", :as => 'day'
  
  match "/collection/:id", :to => 'aggregations#filter', :as => 'collection'
  
  match 'analytics', :to => 'filters#new', :as => 'analytics'
  
  match 'reset_api_token', :to => 'dashboard#reset_user_token', :as => 'reset_api_token'
  
  resources :predictions
  
  resources :search do
    collection do
      get 'everything', :action => 'everything'
      get 'everything/:query', :action => 'everything'
    end
  end
  
  resources :calendar do
    collection do
      get 'today'
      get 'today/:what', :action => 'today'
      get 'tomorrow'
      get 'tomorrow/:what', :action => 'tomorrow'
      get 'yesterday'
      get 'yesterday/:what', :action => 'yesterday'
      get 'day'
      get 'day/:year/:month/:day', :action => :day
      get 'day/:year/:month/:day/:what', :action => :day
    end
  end

  resources :visualizations
  resources :contacts do 
    collection do
      get 'botshop'
      get 'thanks'
    end
  end

  resources :aggregations do
    member do
      get 'bundle'
      get 'activities'
      get 'notifications'
      get 'predictions'
    end
  end
  
  resources :notifications do
    member do
      post 'toggle_read'
    end
    collection do
      get 'all'
    end
  end
  
  resources :bundles do 
    member do
      get 'sparkline'
      get 'share'
      post 'add_filter'
      post 'remove_filter'
    end
  end
  
  resources :activities do
    collection do
      post 'filter'
      post 'bundle'
    end
  end

  resources :oauth_clients
  
  resources :apps
  
  resources :filters do
    member do
      post 'add_to_bundle'
      post 'remove_from_bundle'
    end
  end
  
  
  resources :dashboard do
    collection do
      get 'impact'
    end
  end
  
  
  match '/me', :to => 'activities#me', :as => :me
    
  match '/api', :to => 'welcome#api', :as => :api
  match '/developers', :to => 'welcome#developers', :as => :developers
  match '/developers/rails', :to => 'welcome#rails'

  match '/oauth/test_request',  :to => 'oauth#test_request',  :as => :test_request

  match '/oauth/token',         :to => 'oauth#token',         :as => :token

  match '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token

  match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token

  match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize

  match '/oauth/revoke',     :to => 'oauth#revoke',     :as => :revoke

  match '/oauth',               :to => 'oauth#index',         :as => :oauth
  
  root :to => "welcome#index"
  
  mount Resque::Server.new, :at => "/resque"
  
end
