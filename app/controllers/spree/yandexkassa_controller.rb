class Spree::YandexkassaController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:check_order, :payment_aviso]
  before_filter :create_notification, :only => [:check_order, :payment_aviso]

  include OffsitePayments::Integrations

  helper 'spree/store'

  def show
    @order =  Spree::Order.find(params[:order_id])
    @order.state = params[:state] if params[:state]
    @gateway = @order.available_payment_methods.detect{|x| x.id == params[:gateway_id].to_i }

    if @order.blank? || @gateway.blank?
      flash[:error] = I18n.t("invalid_arguments")
      redirect_to :back
    else
      # Находим оплату для яндекскассы
      payment = @order.payments.select{ |p| p.payment_method.kind_of? Spree::BillingIntegration::YandexkassaIntegration and p.can_started_processing? }.first
      if payment.nil?
        payment = @order.payments.create(amount: 0, payment_method: @gateway)
      end
      # Выставляем сумму и статус "В обработке"
      payment.amount = @order.total
      payment.save
      payment.started_processing!

      render :action => :show
    end
  end

  def check_order
    if @notification.acknowledge @gateway.options[:password]#Rails.application.config.yandexkassa_shop_password
      order = Spree::Order.find_by id: @notification.item_id
      if order and order.total.to_f == @notification.gross
        # ... process order ...
      else
        @notification.set_response 1
      end
    else
      # ... log possible hacking attempt ...
    end
    render text: @notification.response
  end

  def payment_aviso

  end

  def create_notification
    @notification = Yandexkassa::Notification.new request.raw_post
  end
end