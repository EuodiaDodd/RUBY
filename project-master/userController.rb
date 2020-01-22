require 'erb'
require 'sinatra'
require 'sqlite3'
require 'digest'

include ERB::Util
set :bind, '0.0.0.0'

VALID_HANDLE_REGEX = /^@?(\w){1,15}$/ #From https://stackoverflow.com/questions/8650007/regular-expression-for-twitter-username
                                      #Credit to user 'asenovm'

before do
    @userDB = SQLite3::Database.new './userDatabase.sqlite'
    @adminDB = SQLite3::Database.new 'adminDatabase.sqlite'
end

get '/welcome' do
    response.set_cookie("loggedIn","noUser")
    erb :splashpage
end 

get '/user' do
    response.set_cookie("userState","User")
    @submitted = false
    erb :user
end

get '/history' do
    if request.cookies['userState']=='User'
        if request.cookies['userState'] == 'User'
            query3 = %{SELECT * FROM order_info WHERE twitterhandle = '#{$UHandle}' }
            @historyTable = @adminDB.execute query3
        else
            query3 = %{SELECT * FROM order_info}
            @historyTable = @adminDB.execute query3
        end
        return erb :history
    else 
        puts "404 error"
    end
end 

post '/city_search' do
    @userCity = params[:city].strip
    if request.cookies['userState'] == 'User'
        query3 = %{SELECT * FROM order_info WHERE twitterhandle = '#{$UHandle}' AND city LIKE '%' || ? || '%'}
        @historyTable = @adminDB.execute query3, @userCity
    else
        query3 = %{SELECT * FROM order_info AND city LIKE '%' || ? || '%'}
        @historyTable = @adminDB.execute query3, @userCity
    end
    erb :history
end

get '/offers' do
  if request.cookies['loggedIn'] == 'User'
     @redeemTrigger = false
    offerQuery = %{SELECT * FROM offer_info WHERE twitter_handle = '#{$UHandle}'}
    @offerTable = @adminDB.execute offerQuery
    erb :offers
  else 
     redirect '/user'
  end
   
end

post '/offer_redeemed' do
    @redeemTrigger = true
    @userCode = params[:code].strip
    validQuery = %{SELECT * FROM offer_info WHERE code = '#{@userCode}' AND redeemed = 'no'}
    @offerValidTable = @adminDB.execute validQuery
    @isOfferValid = !@offerValidTable.empty?
    codeQuery = %{UPDATE offer_info SET redeemed='showcode' WHERE code = '#{@userCode}'}
    @adminDB.execute codeQuery
    erb :offers
end

get '/userCars' do
  if request.cookies['loggedIn'] == 'User'
    erb :userCars
  else 
      redirect '/user'
  end
    
end

get '/createAccount' do
    erb :createAccount
end

get '/userAccount' do
    erb :userAccount
end

post '/user_logged_in' do
    @submitted = true

    @userHandle = params[:handle].strip
    $UHandle = @userHandle
    #hashing password
    @userPassword = Digest::SHA256.hexdigest params[:password].strip

    @userHandle_ok = !@userHandle.nil? && @userHandle =~ VALID_HANDLE_REGEX
    @userPassword_ok = !@userPassword.nil? && @userPassword != ""
    
    @validation_ok = @userHandle_ok && @userPassword_ok
    
    @database_ok = false
    
    if @validation_ok
        query = %{SELECT password 
                    FROM user_info
                    WHERE twitter_handle LIKE '%' || ? || '%'}
        result = @userDB.execute query, @userHandle
        if !result.empty?
            if result[0][0] == @userPassword
                @database_ok = true
            end
        end
    
        query2 = %{SELECT * 
                        FROM order_info
                        WHERE twitterhandle LIKE '%' || ? || '%'}
      
    end
    
    @all_ok = @validation_ok && @database_ok
    
    if @all_ok
      response.set_cookie("loggedIn","User")
    end
    erb :user
end


post '/reset_password' do
    
    @reset = true
    @userHandle = params[:handle].strip
    @userHandle_ok = !@userHandle.nil? && @userHandle =~ VALID_HANDLE_REGEX
    
    erb :resetPassword
end

get '/resetPassword' do
    @reset = false
    erb :resetPassword
end

