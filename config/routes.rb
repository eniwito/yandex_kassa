Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  get '/yandexkassa/:gateway_id/:order_id' => 'yandexkassa#show', as: :yandexkassa
  get  '/yandexkassa/success_payment' => 'yandexkassa#success_payment', as: :success_payment
  get  '/yandexkassa/failed_payment' => 'yandexkassa#failed_payment', as: :failed_payment

  # Временно
  get  '/yandexkassa/success_order' => 'yandexkassa#success_payment'
  get  '/yandexkassa/failed_order' => 'yandexkassa#failed_payment'

  post '/yandexkassa/check_order' => 'yandexkassa#check_order'
  post '/yandexkassa/payment_aviso' => 'yandexkassa#payment_aviso'

  # Временно
  post '/yandexkassa/aviso_order' => 'yandexkassa#payment_aviso'

  post '/yandexkassa/test_check_order' => 'yandexkassa#check_order'
  post '/yandexkassa/test_payment_aviso' => 'yandexkassa#payment_aviso'
end
