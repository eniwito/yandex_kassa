module Spree
  class BillingIntegration::YandexkassaIntegration < BillingIntegration
    preference :shopId, :string
    preference :scid, :string
    preference :password, :string

    # Creating all payment methods
    %w(AC PC MC GP WM SB MP AB MA PB QW KV QP).each { |method| preference "payment_method_#{method}".to_sym, :boolean }

    # Limits for payment methods https://money.yandex.ru/doc.xml?id=527483
    preference :lower_limit_AC, :integer, default: 1
    preference :upper_limit_AC, :integer, default: 250000

    preference :lower_limit_PC, :integer, default: 1
    preference :upper_limit_PC, :integer, default: 60000

    preference :lower_limit_MC, :integer, default: 10
    preference :upper_limit_MC, :integer, default: 14000

    preference :lower_limit_GP, :integer, default: 1
    preference :upper_limit_GP, :integer, default: 15000

    preference :lower_limit_WM, :integer, default: 1
    preference :upper_limit_WM, :integer, default: 60000

    preference :lower_limit_SB, :integer, default: 10
    preference :upper_limit_SB, :integer, default: 10000

    preference :lower_limit_MP, :integer, default: 1
    preference :upper_limit_MP, :integer, default: 15000

    preference :lower_limit_AB, :integer, default: 1
    preference :upper_limit_AB, :integer, default: 60000

    preference :lower_limit_MA, :integer, default: 1
    preference :upper_limit_MA, :integer, default: 250000

    preference :lower_limit_PB, :integer, default: 1
    preference :upper_limit_PB, :integer, default: 60000

    preference :lower_limit_QW, :integer, default: 1
    preference :upper_limit_QW, :integer, default: 250000

    preference :lower_limit_KV, :integer, default: 3000
    preference :upper_limit_KV, :integer, default: 100000

    preference :lower_limit_QP, :integer, default: 100
    preference :upper_limit_QP, :integer, default: 5000

    def provider_class
      self.class
    end

    def self.current
      self.where(:type => self.to_s, :environment => Rails.env, :active => true).first
    end


    # @return [Array] of symbols available payment methods
    # depending on order's total price
    # For ex. [:payment_method_AC, :payment_method_MC, :payment_method_PB]
    def available_payment_methods(order)
      amount = order.total
      checked_payment_methods.select { |payment_method| payment_method_in_limit? payment_method, amount }
    end

    private

    # @return [Array] of symbols checked/selected payment methods.
    # For ex. [:payment_method_AC, :payment_method_MC, :payment_method_PB]
    def checked_payment_methods
      defined_preferences.select { |p| p.match /payment_method_/ }.select { |p| options[p] }
    end

    def payment_method_in_limit?(payment_method, amount)
      name = payment_method.to_s.split('_').last

      lower = options["lower_limit_#{name}".to_sym]
      upper = options["upper_limit_#{name}".to_sym]

      amount > lower and amount < upper
    end
  end
end
