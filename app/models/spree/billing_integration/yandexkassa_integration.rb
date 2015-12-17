module Spree
  class BillingIntegration::YandexkassaIntegration < BillingIntegration
    preference :shopId, :string
    preference :scid, :string
    preference :password, :string
  end
end
