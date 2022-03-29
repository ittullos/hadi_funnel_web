class HadiFunnel < Sinatra::Base

  enable :sessions
  set :session_secret, "here be dragons"

  get '/' do
    "Hello World!! :P"
  end

  get '/new_customer' do
    if session[:status] == "customer"
      redirect '/email_thanks'
    else
      erb :email_form
    end

  end

  post '/new_customer' do
    # binding.pry
    @name = params[:post][:name]
    @email = params[:post][:email]
    # open('customers.csv', 'a') { |file|
    #   file << "#{@name},#{@email}\n"
    # }
    # session[:status] = "customer"
    item = FunnelTxn.new
    item.email_address = "isaac@isaac.com"
    item.sent_at = "2019-03-07"
    item.status = "prospect"
    item.name = "isaac"
    item.email_id = "PRO03"
    item.status_date = "2022-03-04"
    item.save
    redirect '/email_thanks'
  end

  get '/email_thanks' do
    erb :email_thanks
  end

end
