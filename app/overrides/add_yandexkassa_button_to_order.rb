Deface::Override.new(:virtual_path => 'spree/orders/show',
                     :name => 'add_yandexkassa_button_to_order',
                     :insert_before => '#order',
                     :partial => 'spree/shared/yandexkassa_button'
)
