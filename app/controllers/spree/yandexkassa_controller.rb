class Spree::YandexkassaController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:check_order, :payment_aviso]
  before_filter :create_notification, :only => [:check_order, :payment_aviso]

  include OffsitePayments::Integrations

  # To avoid error undefined local variable or method `cache_key_for_taxons'
  helper 'spree/store'

  def show
    @order = Spree::Order.find(params[:order_id])
    @order.state = params[:state] if params[:state]
    @gateway = @order.available_payment_methods.detect { |x| x.id == params[:gateway_id].to_i }

    if @order.blank? || @gateway.blank?
      flash[:error] = I18n.t("invalid_arguments")
      redirect_to :back
    else
      # Находим оплату для яндекскассы
      payment = @order.payments.select { |p| p.payment_method.kind_of? Spree::BillingIntegration::YandexkassaIntegration and p.can_started_processing? }.first
      if payment.nil?
        payment = @order.payments.create(amount: 0, payment_method: @gateway)
      end
      # Выставляем сумму и статус "В обработке"
      payment.amount = @order.total
      payment.save
      payment.started_processing!

      # Для правильного адреса в платежной форме надо явно указать среду OffsitePayments
      OffsitePayments.mode = @gateway.options[:test_mode] ? :test : :production
      render :action => :show
    end
  end

  def check_order
    logger.debug "[yandexkassa] check_order started"
    @gateway = Spree::BillingIntegration::YandexkassaIntegration.current
    if @notification.acknowledge @gateway.options[:password]
      logger.debug "[yandexkassa] check notification: true"
      order = Spree::Order.find_by id: @notification.item_id
      # TODO может добавить еще каких нибудь проверок
      if  order and
          order.total.to_f == @notification.gross and
          order.user_id == @notification.customer_id
      # Не делаем ничего, заказ правильный
        logger.debug "[yandexkassa] order correct"
      else
        # В заказе ошибка, выставляем код ошибки
        logger.debug "[yandexkassa] order with error"
        @notification.set_response 1
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
      order = Spree::Order.find_by id: @notification.item_id
      if order
        # TODO надо ли делать транзакцию?
        # robokassa_transaction = Spree::RobokassaTransaction.create

        # Находим оплату для яндекскассы со статусом "В обработке" и подходящей суммой
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

        # Завершаем оплату
        logger.debug "[yandexkassa] payment.complete!"
        payment.complete!

        # Переводим заказ в статус "Оплачен"
        logger.debug "[yandexkassa] order.update!"
        order.update!
        logger.debug "[yandexkassa] order.pay!"
        order.pay!
        logger.debug "[yandexkassa] order.update!"
        order.update!
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

  def create_notification
    logger.debug "[yandexkassa] create_notification"
    @notification = Yandexkassa::Notification.new request.raw_post
    logger.debug "[yandexkassa] notification: #{@notification}"
  end
end