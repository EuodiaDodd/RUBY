# main app controller

require 'erb'
require 'sinatra'
require 'twitter'

set :bind, '0.0.0.0'

require_relative 'userController'
require_relative 'adminController'
require_relative 'createAccountController'
require_relative 'createAdminController'
require_relative 'ordersController'
require_relative 'Cars_controller'

get '/' do 
    erb :splashpage
end 

