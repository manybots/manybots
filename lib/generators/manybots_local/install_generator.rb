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
      
      # def show_readme
      #   readme "README" if behavior == :invoke
      # end
      
    end
  end
end
