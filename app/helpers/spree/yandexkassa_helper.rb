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

  # @return [Array] of symbols checked payment methods.
  # For ex. [:payment_method_AC, :payment_method_MC, :payment_method_PB]
  def checked_payment_methods(gateway)
    gateway.defined_preferences.select { |p| p.match /payment_method_/ }.select { |p| gateway.options[p] }
  end
end