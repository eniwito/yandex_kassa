module Spree::YandexkassaHelper
  # Info field that will be located near user id on the yandex kassa's page
  def yandex_kassa_identity_method(user)
    yandex_kassa_identity_field = Rails.application.config.yandex_kassa_identity
    if user.respond_to? yandex_kassa_identity_field
      user.public_send yandex_kassa_identity_field
    else
      logger.warning "Yandex kassa identity field #{yandex_kassa_identity_field} not found for user. Using email field instead"
      user.email
    end
  end

  CREDIT_FIELDS = %w(category_code goods_name goods_description goods_quantity goods_cost)

  # mapping needed fields fields for credit
  def map_credit_fields(order)
    1.upto(order.line_items.count) do |i|
      CREDIT_FIELDS.each do |field|
        OffsitePayments::Integrations::Yandexkassa::Helper.mapping "#{field}_#{i}".to_sym, "#{field}_#{i}" unless OffsitePayments::Integrations::Yandexkassa::Helper.mappings["#{field}_#{i}".to_sym].present?
      end
    end
  end

  def yandex_kassa_credit?
    Spree::BillingIntegration::YandexkassaIntegration.all.any? { |y| y.preferences[:payment_method_KV] }
  end
end