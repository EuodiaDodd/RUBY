module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the splash page/
      '/welcome'
        
    when /the user login page/
      '/user'
        
    when /the user account page/
        '/user_logged_in'
    when /the user homepage/
        '/userAccount'
        
     when /user login/
        '/user'

     when /admin login/
        '/admin'
     when /the admin login page/
        '/admin'
        
   
     when /the order history page/
        '/history'
     when /the user history page/
        '/history'
        
    when /the cars page/
        '/userCars'
    when /the create new car page/
        '/newCar'

        
    when /the admin homepage/
        '/admin_logged_in'
      
    when /admin/
        '/admin'
    when /user/
        '/user'
        
    when /the create new account page/
        '/createAccount'
    when /the new account page/
        '/create_account'
        
    when /the sending tweets page/ 
        '/messages'

    when /the tweets page/ 
        '/tweets'
    when /the searching tweets page/ 
        '/twitter_search'
    
    when /the orders page/
        '/orders'
    when /the all orders page/
        '/allOrders'
    when /the new order link/
        '/orders'
    when /the create new order page/
        '/orders'
        
    when /the all orders link/
        '/ordersTable'
    when /the all orders page/
        '/ordersTable'
        
    when /the offers page/
        '/offers'
    
        
        
        
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"

    end
  end

    

end

World(NavigationHelpers)
