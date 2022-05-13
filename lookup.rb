require "sinatra/json"

class Lookup < Sinatra::Base
  TITO_SECRET_KEY = ENV["TITO_SECRET_KEY"]

  get "/" do
    erb :index
  end

  get "/lookup" do
    response = HTTP.auth("Bearer #{TITO_SECRET_KEY}").
      get("https://api.tito.io/v3/wearedevelopers/world-congress/tickets.json?version=3.1&search[q]=#{params[:q]}")
    results = response.parse["tickets"]

    if results.any? { |ticket| ticket["reference"] === params[:q] }
      json valid: true
    else
      json valid: false
    end
  end
end
