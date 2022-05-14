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
        "env[TITO_EVENT]=#{params[:tito_event]}",
        "env[TITO_SECRET_KEY]=#{params[:tito_secret_key]}",
        "env[SHARED_SECRET]=#{params[:shared_secret]}",
      ].join("&")

      url = [base, query].join("?")

      redirect url
    end
  else
    get "/" do
      "Try /lookup"
    end
  end

  get "/lookup" do
    if !ENV["TITO_SECRET_KEY"] || ENV["TITO_SECRET_KEY"] == ""
      return "Tito Secret Key is missing"
    end

    if !ENV["TITO_EVENT"] || ENV["TITO_EVENT"] == ""
      return "Tito Event is missing"
    end

    if !secure_compare(params[:shared_secret].to_s, ENV["SHARED_SECRET"].to_s)
      return "Unauthorized"
    end

    response = HTTP.auth("Bearer #{TITO_SECRET_KEY}").
      get("https://api.tito.io/v3/#{TITO_EVENT}/tickets.json?version=3.1&search[q]=#{params[:q]}")

    if response.status == 404
      return json(
        status: response.status,
        message: "Event not found",
        hint: "Check TITO_EVENT"
      )
    elsif response.status == 401
      return json(
        status: response.status,
        message: "Unauthorized",
        hint: "Check TITO_SECRET_KEY"
      )
    elsif response.status > 299
      return json(
        status: response.status,
        message: "Unexpected response from the Tito API"
      )
    end

    tickets = response.parse["tickets"]

    ticket = tickets.find { |ticket| ticket["reference"] === params[:q] }

    if ticket
      json valid: true, name: ticket["name"]
    else
      json valid: false
    end
  end
end
