require "sinatra"
require "sinatra/json"
configure { set :server, :puma }

class Lookup < Sinatra::Base
  TITO_EVENT = ENV["TITO_EVENT"]
  TITO_SECRET_KEY = ENV["TITO_SECRET_KEY"]

  get "/" do
    erb :index
  end

  get "/lookup" do
    response = HTTP.auth("Bearer #{TITO_SECRET_KEY}").
      get("https://api.tito.io/v3/#{TITO_EVENT}/tickets.json?version=3.1&search[q]=#{params[:q]}")
    tickets = response.parse["tickets"]

    ticket = tickets.find { |ticket| ticket["reference"] === params[:q] }

    if ticket
      json valid: true, name: ticket["name"]
    else
      json valid: false
    end
  end
end
