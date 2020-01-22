require 'erb'
require 'sinatra'
require 'sqlite3'
require 'digest'

include ERB::Util
set :bind, '0.0.0.0'

before do 
    @adminDB = SQLite3::Database.open './adminDatabase.sqlite'
end

get '/createAdmin' do
    @submitted = false
    erb :createAdmin
end

get '/adminAccount' do
    erb :adminAccount
end

post '/create_admin' do
    
    @submitted = true
    
    #sanitize values
    @name = params[:name].strip
    @username = params[:username].strip
    @password = params[:password]
    @passwordRepeat = params[:passwordRepeat]
    
    #perform validation
    @name_ok = !@name.nil? && @name != ""
    @username_ok = !@username.nil? && @username != ""
    @password_ok = !@password.nil? && @password != "" && @password == @passwordRepeat
    @repeatpassword_ok = !@passwordRepeat.nil? && @passwordRepeat != "" && @passwordRepeat == @password
    
    count = @adminDB.get_first_value('SELECT COUNT(*) FROM admin_info WHERE username = ?',[@username])
    @unique = (count == 0)
    
    @all_ok = @name_ok && @username_ok && @password_ok && @unique && @repeatpassword_ok
        
    #add data to the database
    if @all_ok 
        #get next available id
        id_check = @adminDB.get_first_value 'SELECT MAX(id) FROM admin_info'
        if id_check.nil?
            id = 1
        else
            id = id_check + 1
        end
        
        #hash password
        hashed_password = Digest::SHA256.hexdigest @password
        #do the insert
        @adminDB.execute(
            'INSERT INTO admin_info VALUES (?,?,?,?)',
            [id,@name,@username,hashed_password])
    end
    erb :createAdmin
end