require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about' do
  @error = 'Something wrong!'
  erb :about
end

get '/visit' do
  erb :visit
end

post '/visit' do
  @user_name  = params[:user_name]
  @phone      = params[:phone]
  @date_time  = params[:date_time]
  @barber     = params[:barber]
  @color      = params[:color]

  hh = { user_name: 'Введите имя', phone: 'Введите телефон', date_time: 'Введите дату и время'}

  hh.each do |key, val|
    if params[key] == ''
      @error = hh[key]
      return erb :visit
    end
  end

  file = File.open('./Public/users.txt', 'a')
  file.write "Имя пользователя: #{@user_name}, телефон: #{@phone}, время записи: #{@date_time}, ваш парикмахер - #{@barber},  цвет: #{@color};\n"
  file.close

  erb "Имя пользователя: #{@user_name}, телефон: #{@phone}, время записи: #{@date_time}, ваш парикмахер - #{@barber},  цвет: #{@color};\n"
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @email    = params[:email]
  @phone    = params[:phone]
  @message  = params[:message]

  file = File.open('./Public/contacts.txt', 'a')
  file.write "Email: #{@email}, телефон: #{@phone}\nсообщение: #{@message}\n\n"
  file.close

  erb :contacts
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  @login      = params[:login]
  @password   = params[:password]

  if @login == 'admin' && @password == 'secret'
    session[:identity] = params['username']
    where_user_came_from = session[:previous_url] || '/'
    # redirect to where_user_came_from

    erb "You are logged in!"
  else 
    erb "Wrong password or login!"
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
