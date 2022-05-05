require 'sinatra'
require 'date'

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
    item.created_at = Time.now.to_i
    date = Time.new
    item.created_date = "#{date.strftime("%Y")}-#{date.strftime("%m")}-#{date.strftime("%d")}"
    item.name = @name
    item.save
    redirect '/Prod/funnel/email_thanks'
  end

  get '/funnel/email_thanks' do
    erb :email_thanks
  end

end
