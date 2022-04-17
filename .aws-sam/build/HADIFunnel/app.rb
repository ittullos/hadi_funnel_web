require 'sinatra'

class HadiFunnel < Sinatra::Base

  enable :sessions
  set :session_secret, "here be dragons"

  get '/' do
    "Hello World!! :P"
  end

  get '/funnel/new_customer' do
    if session[:status] == "customer"
      redirect '/Prod/funnel/email_thanks'
    else
      erb :email_form
    end

  end

  post '/funnel/new_customer' do
    # binding.pry
    @name = params[:post][:name]
    @email = params[:post][:email]
    # open('customers.csv', 'a') { |file|
    #   file << "#{@name},#{@email}\n"
    # }
    session[:status] = "customer"
    item = FunnelTxn.new
    item.email_address = @email
    item.sent_at = Time.new
    item.status = "prospect"
    item.name = @name
    item.email_id = "PRO03"
    item.status_date = "2022-03-04"
    item.save
    redirect '/Prod/funnel/email_thanks'
  end

  get '/funnel/email_thanks' do
    erb :email_thanks
  end

end
