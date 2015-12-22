module Spree
  class BillingIntegration::YandexkassaIntegration < BillingIntegration
    preference :shopId, :string
    preference :scid, :string
    preference :password, :string

    def provider_class
      self.class
    end

    def self.current
      self.where(:type => self.to_s, :environment => Rails.env, :active => true).first
    end
  end
end
