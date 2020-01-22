
require 'erb'
require 'sinatra'
require 'twitter'
require 'sqlite3'

include ERB::Util
set :bind, '0.0.0.0'

before do 
    @adminDB = SQLite3::Database.open './adminDatabase.sqlite'
end


get '/orders' do
  if request.cookies['loggedIn'] == 'Admin'
    @submitted = false
    @status = params[:status]
    @results = @adminDB.execute('SELECT * FROM order_info')
    erb :orders
  else 
    erb:admin
  end
    
end


get '/allOrders' do
  if request.cookies['loggedIn'] == 'Admin'
      @submitted = false
    @results = @adminDB.execute('SELECT * FROM order_info')
    erb :allOrders
  else 
    erb:admin
  end
  
end

post '/orders' do
    
    @submitted = true
    
    #sanitize values
    @origin = params[:origin].strip
    @destination = params[:destination].strip
    @car = params[:car].strip
    @twitter_handle = params[:twitterhandle].strip
    @city = params[:city].strip
    
    @current_status = "Ongoing"
    
    d = DateTime.now
    @date = d.strftime("%d/%m/%Y")
    
    t = Time.now
    @time = t.strftime("%H:%M")
    
    #perform validation
    @origin_ok = !@origin.nil? && @origin != ""
    @destination_ok = !@destination.nil? && @destination != ""
    @car_ok = !@car.nil? && @car != ""
    @twitterhandle_ok = !@twitter_handle.nil? && @twitter_handle[0]=='@'
    @city_ok = !@city.nil? && @city != ""
    
    @all_ok = @origin_ok && @destination_ok && @car_ok && @twitterhandle_ok && @city_ok
        
    #add data to the database
    if @all_ok 
        #get next available id
        id_check = @adminDB.get_first_value 'SELECT MAX(order_id) FROM order_info'
        if id_check.nil?
            order_id = 1
        else
            order_id = id_check + 1
        end
            
        #do the insert
        @adminDB.execute(
            'INSERT INTO order_info VALUES (?,?,?,?,?,?,?,?,?)',
            [order_id, @twitter_handle, @origin, @destination, @car, @date, @time, @current_status, @city])
        
        #save the results in a variable so that they can be added to the table
        @results = @adminDB.execute('SELECT * FROM order_info')
    end
    results = @client.mentions_timeline()
    @tweets = results.take(20)
    erb :orders
end

post '/completeOrder' do
        #update order_info table in the database
        @order_number = params[:orderNumber]
    
        changeStatus = %{UPDATE order_info SET status = "Completed" WHERE order_id = '#{@order_number}'}
        @adminDB.execute changeStatus
        @results = @adminDB.execute('SELECT * FROM order_info')
    
        results = @client.mentions_timeline()
        @tweets = results.take(20)
    
     erb :adminAccount
end
 
post '/cancelOrder' do
        #update order_info table in the database
        @order_number = params[:orderNumber]
    
        changeStatus = %{UPDATE order_info SET status = "Cancelled" WHERE order_id = '#{@order_number}'}
        @adminDB.execute changeStatus
        @results = @adminDB.execute('SELECT * FROM order_info')
    
        results = @client.mentions_timeline()
        @tweets = results.take(20)
    erb :adminAccount
end