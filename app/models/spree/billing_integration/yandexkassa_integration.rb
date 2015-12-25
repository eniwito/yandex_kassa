module Spree
  class BillingIntegration::YandexkassaIntegration < BillingIntegration
    preference :shopId, :string
    preference :scid, :string
    preference :password, :string

    # Creating all payment methods
    %w(AC PC MC GP WM SB MP AB MA PB QW KV QP).each { |method| preference "payment_method_#{method}".to_sym, :boolean }

    def provider_class
      self.class
    end

    def self.current
      self.where(:type => self.to_s, :environment => Rails.env, :active => true).first
    end
  end
end
