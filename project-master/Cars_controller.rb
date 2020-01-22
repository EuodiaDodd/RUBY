require 'erb'
require 'sinatra'
require 'twitter'
require 'sqlite3'

include ERB::Util
set :bind, '0.0.0.0'


before do 
    @adminDB = SQLite3::Database.open './adminDatabase.sqlite'
end

get '/carsTable' do
  if request.cookies['loggedIn'] == 'Admin'
    @submitted = false
    return erb :carsTable
  else 
     redirect '/admin'
  end
    
end

get '/cars' do
  if request.cookies['loggedIn'] == 'Admin'
    @submitted = false
    @results = @adminDB.execute('SELECT * FROM car_info')
    erb :cars
  else 
     redirect '/admin'
  end
    
end

get '/newCar' do
  if request.cookies['loggedIn'] == 'Admin'
     @submitted = false
    return erb :newCar
  else 
     redirect '/admin'
  end
   
end 

post '/newCar' do
    
    @submitted = true
    
    #sanitize values

    @car_model = params[:Car_model].strip
    @number_of_seats = params[:Number_of_seats].strip
    @car_registration = params[:Car_registration].strip
    @car_colour = params[:Car_colour].strip
    @status = "Ongoing"

    
    #perform validation
    @car_model_ok = !@car_model.nil? && @car_model != ""
    @number_of_seats_ok = !@number_of_seats.nil? && @number_of_seats != ""
    @car_registration_ok = !@car_registration.nil? && @car_registration != ""
    @car_colour_ok = !@car_colour.nil? && @car_colour != ""

    @all_ok = @car_model_ok && @number_of_seats_ok && @car_registration_ok && @car_colour_ok
        
    #add data to the database
    if @all_ok 
        #get next available id
        id_check = @adminDB.get_first_value 'SELECT MAX(order_id)FROM car_info'
        if id_check.nil?
            order_id = 1
        else
            order_id = id_check + 1
        end
            
        #do the insert
        @adminDB.execute(
            'INSERT INTO car_info VALUES (?,?,?,?,?,?)',
            [order_id, @car_model, @number_of_seats, @car_registration, @car_colour, @status])
        
        #save the results in a variable so that they can be added to the table
        @results = @adminDB.execute('SELECT * FROM car_info')
    end
    erb :cars
end   
