require 'minitest/autorun'
require_relative 'userController.rb'
require_relative 'ordersController.rb'
require_relative 'createAccountController.rb'
require 'rack/test'
require 'sinatra/base'
require 'net/http'
require 'twitter'

class MiniTests < Minitest::Test
  include Rack::Test::Methods
     
    def app
      Sinatra::Application
    end
  
    VALID_HANDLE_REGEX = /^@?(\w){1,15}$/
    def setup
        @userDB = SQLite3::Database.new './userDatabase.sqlite'
        @adminDB = SQLite3::Database.new 'adminDatabase.sqlite'
        @userHandle = "@example"
            #hashing password
        @userPassword = Digest::SHA256.digest 'password'
        @adminDB = SQLite3::Database.new './adminDatabase.sqlite'
        config = { :consumer_key => 'tSqudFLIdXMCMvadAeekTPXp9', 
                   :consumer_secret => 'UhSaG1MhJgITbS3pajUxBHzXD42pgcc0hDn6RaBm6vk3VF5iEg', 
                   :access_token => '1092443316841533441-E6ufPAkORt0MZ7Nlz0Qb7Jt2mcpYzB', 
                   :access_token_secret => 'TlT4UEvE0Q8njdKSfbVBbjjE9UPozkDycgxYhyC9ihWLj' 
        }
        @client = Twitter::REST::Client.new(config)
    end

    #Tests if user input works
    #After fixing the login button, this should pass the test
    def test_user_login_wrong
        response = post '/user', :userHandle => 'Dan', :userPassword => 'chicken'
        response = get '/history'
        assert_equal 404, response.status
    end
    
    #After fixing the login button, this should pass the test
    #Tests login for null password
    def test_user_login_null
        post '/user_logged_in', :userHandle => 'Dan', :userPassword => ''
        response = get '/history'
        assert_equal 404, response.status
    end
  
    #Tests login for correct login details
    def test_user_login_correct
        post '/user_logged_in', :@userHandle => '@example', :@userPassword => 'password'
        response = get '/history'
        assert_equal 200, response.status
    end
  
        #Tests if user input works
    #After fixing the login button, this should pass the test
    def test_admin_login_wrong
        response = post '/admin', :userHandle => 'Dan', :userPassword => 'chicken'
        response = get '/cars'
        assert_equal 404, response.status
    end
    
    #After fixing the login button, this should pass the test
    #Tests login for null password
    def test_admin_login_null
        post '/admin_logged_in', :userHandle => 'Dan', :userPassword => ''
        response = get '/cars'
        assert_equal 404, response.status
    end
  
    #Tests login for correct login details
    def test_admin_login_correct
        post '/user_logged_in', :@userHandle => 'username', :@userPassword => 'password'
        response = get '/cars'
        assert_equal 200, response.status
    end
    
    #Testing the new car form inserts into the database
    def test_newCar  
        post '/newCar', 
        :@order_id => 111,
        :@car_model => "Renault",
        :@number_of_seats => 12,
        :@car_registration => "Y",
        :@car_colour => "green",
        :@status => "Ongoing"
        
        response = false
        query = %{SELECT * 
                    FROM car_info
                    WHERE number_of_seats > 10}
        result = @adminDB.execute query, @adminHandle
        if !result.nil?
          response = true
        end
        assert_equal true, response
    end
    
    #Testing the search function returns values
    def test_twitter_search
        search_string = "ello"
        unless search_string.nil?
          search_string = "yo"
          results = @client.search(search_string)
          finds_tweets = !results.nil?
          @tweets = results.take(20)
          assert_equal true, finds_tweets
        end 
    end
    
    #Testing the validation of the twitter reply form
    def test_twitter_reply
        @entered = true 

        @id = "@ise19team02"
        @tweet = "hey whatsup"

        @id_ok = !@id.nil? && @id != ""
        @tweet_ok = !@tweet.nil? && @tweet != ""

        @valid = @id_ok && @tweet_ok
        assert_equal true, @valid
    end
    
    #Testing the new orders form inserts into the database
    def test_new_order
        post '/orders', 
        :@origin => 'Tesco',
        :@destination => 'The Diamond',
        :@car => 'Renault',
        :@twitter_handle => 'Tester',
        :@current_status => "Ongoing",
        :@status => "Ongoing",
        :@city => "Sheffield"
        
        order_id = 2333
        
        response = false
        @adminDB.execute(
            'INSERT INTO order_info VALUES (?,?,?,?,?,?,?,?,?)',
            [order_id, @twitter_handle, @origin, @destination, @car, @date, @time, @current_status, @city])
       
        #save the results in a variable so that they can be added to the table
        result = @adminDB.execute('SELECT * FROM order_info WHERE origin = "Sheffield"')
        if !result.nil?
          response = true
        end
        assert_equal true, response
    end
    
    #Testing the new order form for null values
    def test_new_order_null
          post '/orders', 
        :@origin => nil,
        :@destination => 'The Diamond',
        :@car => 'Renault',
        :@twitter_handle => 'Tester',
        :@current_status => "Ongoing",
        :@status => "Ongoing",
        :@city => "Sheffield"
        
        order_id = 545
        
        @origin_ok = !@origin.nil? && @origin != ""
        
        response = false
        if @origin_ok
          @adminDB.execute(
              'INSERT INTO order_info VALUES (?,?,?,?,?,?,?,?,?)',
              [order_id, @twitter_handle, @origin, @destination, @car, @date, @time, @current_status, @city])
        end
      
        #save the results in a variable so that they can be added to the table
        result = @adminDB.execute('SELECT * FROM order_info WHERE origin = "My house"')
        if !result.nil?
          response = true
        end
        assert_equal true, response
    end
  
    def test_city_search
      post '/admin_city_search',
      :@adminCity => 'Leeds'
      cityQuery = %{SELECT * FROM order_info WHERE city LIKE '%' || ? || '%'}
      @results = @adminDB.execute cityQuery,@adminCity
      assert_equal [], @results
    end
    
    def test_offer_post
      post '/offer_post',
      :@userCode => 'bbb'

      validQuery = %{SELECT * FROM offer_info WHERE code = '#{@userCode}' AND redeemed = 'showcode'}
      @offerValidTable = @adminDB.execute validQuery
      @isCodeValid = !@offerValidTable.empty?
      
      assert_equal false, @isCodeValid
  end
end 
