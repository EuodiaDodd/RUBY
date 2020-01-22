require 'erb'
require 'sinatra'
# require 'twitter'
require 'sqlite3'
require 'digest'

include ERB::Util
set :bind, '0.0.0.0'

before do 
    @userDB = SQLite3::Database.open './userDatabase.sqlite'
end


get '/createAccount' do
    @submitted = false
    erb :createAccount
end

get '/userAccount' do
    erb :userAccount
end

post '/create_account' do
    
    @submitted = true
    
    #sanitize values
    @name = params[:name].strip
    @twitter_handle = params[:handle].strip
    @password = params[:password]
    @passwordRepeat = params[:passwordRepeat]
    
    #perform validation
    @name_ok = !@name.nil? && @name != ""
    @twitter_handle_ok = !@twitter_handle.nil? && @twitter_handle[0]=='@'
    @password_ok = !@password.nil? && @password != "" && @password==@passwordRepeat
    
    count = @userDB.get_first_value('SELECT COUNT(*) FROM user_info WHERE twitter_handle = ?',[@twitter_handle])
    @unique = (count == 0)
    
    @all_ok = @name_ok && @twitter_handle_ok && @password_ok && @unique
        
    #add data to the database
    if @all_ok 
        #get next available id
        id_check = @userDB.get_first_value 'SELECT MAX(id) FROM user_info'
        if id_check.nil?
            id = 1
        else
            id = id_check + 1
        end
        
        #hash password
        hashed_password = Digest::SHA256.hexdigest @password
        #do the insert
        @userDB.execute(
            'INSERT INTO user_info VALUES (?,?,?,?)',
            [id,@name,@twitter_handle,hashed_password])
    end
    erb :createAccount 
end