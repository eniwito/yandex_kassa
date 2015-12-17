Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  get '/yandexkassa/:gateway_id/:order_id' => 'yandexkassa#show', as: :yandexkassa
  post '/yandexkassa/check_order' => 'yandexkassa#check_order'
  post '/yandexkassa/payment_aviso' => 'yandexkassa#payment_aviso'
end
