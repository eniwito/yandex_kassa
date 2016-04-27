class Spree::YandexkassaController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:check_order, :payment_aviso]
  before_filter :create_notification, :only => [:check_order, :payment_aviso]

  include OffsitePayments::Integrations
  include Spree::YandexkassaHelper

  # To avoid error undefined local variable or method `cache_key_for_taxons'
  helper 'spree/store'

  helper 'spree/orders'

  def show
    @order = Spree::Order.find_by(number: params[:order_number])
    @order.state = params[:state] if params[:state]
    @gateway = @order.available_payment_methods.detect { |x| x.id == params[:gateway_id].to_i }
    # Available(checked) payments methods for Yandexkassa
    # @payment_methods = @gateway.checked_payment_methods

    @payment_methods = @gateway.available_payment_methods @order

    if @order.blank? || @gateway.blank?
      flash[:error] = I18n.t("invalid_arguments")
      redirect_to :back
    else
      # Find payment for Yandexkassa
      payment = @order.payments.select { |p| p.payment_method.kind_of? Spree::BillingIntegration::YandexkassaIntegration and p.can_started_processing? }.first
      if payment.nil?
        payment = @order.payments.create(amount: 0, payment_method: @gateway)
      end
      # Set amount and start processing
      payment.amount = @order.total
      payment.save
      payment.started_processing!

      # For correct path in payment form we need set mode for OffsitePayments
      OffsitePayments.mode = @gateway.options[:test_mode] ? :test : :production
      render :action => :show
    end
  end

  def check_order
    logger.debug "[yandexkassa] check_order started"
    @gateway = Spree::BillingIntegration::YandexkassaIntegration.current
    if @notification.acknowledge @gateway.options[:password]
      logger.debug "[yandexkassa] check notification: true"
      order = Spree::Order.find_by number: @notification.item_id
      logger.debug "[yandexkassa] order #{order.inspect}"
      if not order
        @notification.message = Spree.t :order_not_found
      elsif order.total.to_f < @notification.gross
        @notification.message = Spree.t :payment_more_than_order_price
      elsif order.user_id != @notification.customer_id.split.first.to_i
        @notification.message = Spree.t :order_belongs_to_another_user
        # Order with error. Set error code
        logger.debug "[yandexkassa] order with error #{@notification.message}"
        @notification.set_response 1
      else
        # Do nothing. Order correct.
        logger.debug "[yandexkassa] order correct"
        @notification.set_response 0
      end
    else
      logger.debug "[yandexkassa] check notification: false"
    end
    logger.debug "[yandexkassa] response #{@notification.response}"
    render text: @notification.response
  end

  def payment_aviso
    logger.debug "[yandexkassa] payment_aviso started"
    @gateway = Spree::BillingIntegration::YandexkassaIntegration.current
    if @notification.acknowledge @gateway.options[:password]
      logger.debug "[yandexkassa] check notification: true"
      order = Spree::Order.find_by number: @notification.item_id
      if order
        # TODO надо ли делать транзакцию?
        # robokassa_transaction = Spree::RobokassaTransaction.create

        # Find payment for Yandexkassa with status processing and equal amount
        payment = order.payments.select { |p| p.payment_method.kind_of? Spree::BillingIntegration::YandexkassaIntegration and p.processing? and p.amount.to_f == @notification.gross }.first
        logger.debug "[yandexkassa] payment: #{payment}"
        if payment.nil?
          logger.debug "[yandexkassa] creating payment"
          payment = order.payments.create(amount: @notification.gross,
                                          payment_method: @gateway) #,
          # source: robokassa_transaction)
          logger.debug "[yandexkassa] payment: #{payment}"
          logger.debug "[yandexkassa] payment.started_processing!"
          payment.started_processing!
        end

        # Complete payment
        logger.debug "[yandexkassa] payment.complete!"
        payment.complete!

        if order.payment_total?
          # Change order state to paid.
          logger.debug "[yandexkassa] order.update!"
          order.update!
          logger.debug "[yandexkassa] order.pay!"
          order.pay!
          logger.debug "[yandexkassa] order.update!"
          order.update!
        end

        @notification.set_response 0
      else
        logger.debug "[yandexkassa] order not found"
        @notification.set_response 1
      end
    else
      logger.debug "[yandexkassa] check notification: false"
    end
    logger.debug "[yandexkassa] response #{@notification.response}"
    render text: @notification.response
  end

  def success_payment

  end

  def failed_payment

  end

  def create_notification
    logger.debug "[yandexkassa] create_notification"
    @notification = Yandexkassa::Notification.new request.raw_post
    logger.debug "[yandexkassa] notification: #{@notification.inspect}"
  end
end