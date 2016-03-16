# spree_backend-2.3.1/app/views/spree/admin/taxons/_form.html.erb

include Spree::YandexkassaHelper

# If any of yandexkassa`s instances has credit payment preference
if yandex_kassa_credit?
  Deface::Override.new(:virtual_path => 'spree/admin/taxons/_form',
                       :name => 'add_category_code_to_taxon_edit',
                       :insert_bottom => '[data-hook=admin_inside_taxon_form]',
                       :partial => 'spree/admin/taxons/category_code'
  )
end