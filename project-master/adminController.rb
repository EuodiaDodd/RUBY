require 'erb'
require 'sinatra'
require 'twitter'
require 'sqlite3'
require 'digest'
set :sessions => true

include ERB::Util
set :bind, '0.0.0.0'

# controller for the admin side
before do
  @adminDB = SQLite3::Database.new './adminDatabase.sqlite'
  config = { :consumer_key => 'tSqudFLIdXMCMvadAeekTPXp9', 
             :consumer_secret => 'UhSaG1MhJgITbS3pajUxBHzXD42pgcc0hDn6RaBm6vk3VF5iEg', 
             :access_token => '1092443316841533441-E6ufPAkORt0MZ7Nlz0Qb7Jt2mcpYzB', 
             :access_token_secret => 'TlT4UEvE0Q8njdKSfbVBbjjE9UPozkDycgxYhyC9ihWLj' 
  }
  @client = Twitter::REST::Client.new(config)
end
    
VALID_HANDLE_REGEX = /^@?(\w){1,15}$/


get '/admin' do
      response.set_cookie("userState","Admin")
      @submitted = false
      @results = @adminDB.execute('SELECT * FROM order_info')
      erb :admin
end


get '/createAdmin' do
  if request.cookies['loggedIn'] == 'Admin'
    erb :createAdmin
  else 
    redirect '/admin'
  end   
end

get '/adminAccount' do
  if request.cookies['loggedIn'] == 'Admin'
    @results = @adminDB.execute('SELECT * FROM order_info')
    
    results = @client.mentions_timeline()
    @tweets = results.take(20)
    
    erb :adminAccount
  else 
     redirect '/admin'
  end
    
end

get '/tweetsTable' do
    return erb :tweetsTable
end

get '/tweets' do
  if request.cookies['loggedIn'] == 'Admin'
      results = @client.mentions_timeline()
      @tweets = results.take(20)
      @tweetHash = Hash.new
      @repHash = Hash.new

      @tweets.each do |tweet|

        if tweet.in_reply_to_status_id != nil
          @replyID = tweet.in_reply_to_status_id
          @tweetHash[@replyID] = tweet.text
        end

      end
    erb :tweets
  else
     redirect '/admin'
  end
end

get '/adminHistory' do
  if request.cookies['loggedIn'] == 'Admin'
    @results = @adminDB.execute('SELECT * FROM order_info')
    erb :adminHistory
  else 
     redirect '/admin'
  end
    
end 

post '/admin_city_search' do
    @adminCity = params[:city].strip
    cityQuery = %{SELECT * FROM order_info WHERE city LIKE '%' || ? || '%'}
    @results = @adminDB.execute cityQuery,@adminCity
    erb :adminHistory
 
end

get '/messages' do
  if request.cookies['loggedIn'] == 'Admin'
     erb :adminMessages
  else 
     redirect '/admin'
  end
   
end 

get '/twitter_search' do 
  if request.cookies['loggedIn'] == 'Admin'
    unless params[:search].nil?
        search_string = params[:search]
        results = @client.search(search_string)
        @tweets = results.take(20)
    end 
    erb :twitterSearch
  else 
     redirect '/admin'
  end
    
end 

get '/adminOffers' do
  if request.cookies['loggedIn'] == 'Admin'
    @isCodeValid = true
    offerAdminQuery = %{SELECT * FROM offer_info WHERE redeemed = 'showcode'OR redeemed = 'no'}
    @adminOfferTable = @adminDB.execute offerAdminQuery
    erb :adminOffers
  else 
     redirect '/admin'
  end
    
end

post '/offer_post' do
  
    @userCode = params[:code].strip
    
    validQuery = %{SELECT * FROM offer_info WHERE code = '#{@userCode}' AND redeemed = 'showcode'}
    @offerValidTable = @adminDB.execute validQuery
    @isCodeValid = !@offerValidTable.empty?
    
    codeQuery = %{UPDATE offer_info SET redeemed='yes' WHERE code = '#{@userCode}'}
    @adminDB.execute codeQuery
    offerAdminQuery = %{SELECT * FROM offer_info WHERE redeemed = 'showcode' OR redeemed = 'no'}
    @adminOfferTable = @adminDB.execute offerAdminQuery
    erb :adminOffers

end

get '/createOffer' do
  if request.cookies['loggedIn'] == 'Admin'
    @possibleOffers = ["50% OFF", "80% OFF","FREE TRIP","FREE TRIP UNDER £20"]
    erb :createOffer
  else 
     redirect '/admin'
  end
    
end

post '/create_offer_post' do
     @submitted = true
    code_ok = true
    @possibleOffers = ["50% OFF", "80% OFF","FREE TRIP","FREE TRIP UNDER £20"]
    @generatedCode = ""
    
    while code_ok
    
        letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        (0..5).each do |i|
            randomNo = rand(25)
            @generatedCode = @generatedCode + letters[randomNo]
        end
        
        randCodeQuery = %{SELECT code FROM offer_info WHERE code = '#{@generatedCode}'}
        codeResult = @adminDB.execute randCodeQuery
        code_ok = !codeResult.empty?
        
    end
    @offerName = params[:offerName].strip
    @userHandle = params[:userHandle].strip
    
    @offerName_ok = false
    @possibleOffers.each do |i| 
        if @offerName == i
            @offerName_ok = true
        end
    end
    
    @userHandle_ok = !@userHandle.nil?
    
    @offer_ok = @userHandle_ok && @offerName_ok
    
    if @offer_ok
        puts "#{@userHandle},#{@generatedCode},#{@offerName},no"
        offerAddQuery = %{INSERT INTO offer_info(twitter_handle,code,offer_type,redeemed)
        VALUES ('#{@userHandle}','#{@generatedCode}','#{@offerName}','no')}
        @adminDB.execute offerAddQuery
    end
    erb :createOffer 
end

post '/admin_logged_in' do
    @submitted = true
    @admin_logged_in = true 
    
    @adminUsername = params[:username].strip
    @adminPassword = Digest::SHA256.hexdigest params[:password].strip  #removed from before params, Digest::SHA256.digest

    @adminUsername_ok = !@adminUsername.nil? && @adminUsername != ""   #@adminUsername =~ VALID_HANDLE_REGEX
    @adminPassword_ok = !@adminPassword.nil? && @adminPassword != ""

    @validation_ok = @adminUsername_ok && @adminPassword_ok
    
    
  
    @database_ok = false
    @results = @adminDB.execute('SELECT * FROM order_info')
    
    results = @client.mentions_timeline()
  @tweets = results.take(20)
  @tweetHash = Hash.new
  @repHash = Hash.new
  
  @tweets.each do |tweet|
     
    if tweet.in_reply_to_status_id != nil
      @replyID = tweet.in_reply_to_status_id
      @tweetHash[@replyID] = tweet.text
    end
    
  end
    
    #checks the password against the password stored in the database for a given username
    if @validation_ok
        query = %{SELECT password 
                    FROM admin_info
                    WHERE username LIKE '%' || ? || '%'}
        result = @adminDB.execute query, @adminUsername

        if !result.empty?
            if result[0][0] == @adminPassword
                @database_ok = true
            end
        end
    end
    
    @all_ok = @validation_ok && @database_ok
    if @all_ok
       response.set_cookie('loggedIn','Admin')
    end
    erb :admin
end

post '/form_handler' do
  
    @entered = true 
    @tweet = params[:tweet].strip

    @tweet_ok = !@tweet.nil? && @tweet != ""

    @valid = @tweet_ok
    @client.update("#{@tweet}", :in_reply_to_status_id => @id)
   
    erb :adminMessages
end

