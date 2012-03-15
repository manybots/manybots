require 'rails/generators'
require 'rails/generators/base'


module ManybotsLocal
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      
      source_root File.expand_path("../../templates", __FILE__)
            
      desc "Create initializers with dynamic Tokens (Devise and Session pepper)"
      def copy_initializer
        template "devise.rb.tt", "config/initializers/devise.rb"
        template "secret_token.rb.tt", "config/initializers/secret_token.rb"
      end
      
      desc 'Add Devise route'
      def add_devise_route
        route devise_route_data        
      end
      
      
      # def show_readme
      #   readme "README" if behavior == :invoke
      # end
      
      private 
        
        def devise_route_data
<<RUBY
devise_for :users do
    get "/login" => "devise/sessions#new"
    get "/logout" => "devise/sessions#destroy"
    get "/account" => "devise/registrations#edit"
    get "/account/password" => "dashboard#password"
    post "/account/update_password" => "dashboard#update_password"
  end
RUBY
        end
      
    end
  end
end
