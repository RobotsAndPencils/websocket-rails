Rails.application.routes.draw do
  if Rails.version >= '4.0.0'
    get "/websocket", :to => WebsocketRails::ConnectionManager.new
  else
    get "/websocket", :to => WebsocketRails::ConnectionManager.new
  end
end
