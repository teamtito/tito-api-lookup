require "sinatra"
require "sinatra/json"
configure { set :server, :puma }

class Lookup < Sinatra::Base
  TITO_EVENT = ENV["TITO_EVENT"]
  TITO_SECRET_KEY = ENV["TITO_SECRET_KEY"]

  if ENV["RACK_ENV"] != "production"
    get "/" do
      erb :index
    end

    post "/deploy" do
      base = "https://heroku.com/deploy"

      query = [
        "template=https://github.com/teamtito/tito-api-lookup/tree/main",
        "ENV[TITO_EVENT]=#{params[:tito_event]}",
        "ENV[TITO_SECRET_KEY]=#{params[:tito_secret_key]}",
        "ENV[SHARED_SECRET]=#{params[:shared_secret]}",
      ].join("&")

      redirect [base, query].join("?")
    end
  end

  get "/lookup" do
    if ENV["SHARED_SECRET"]
      if Rack::Utils.secure_compare(params[:shared_secret], ENV["SHARED_SECRET"])
        error 401 do
          { error: "Unauthorized" }
        end
      end
    end

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
