Spree::CheckoutController.class_eval do
  before_filter :redirect_to_yandexkassa_form_if_needed, :only => [:update, :edit]
  helper 'spree/store'

  private

  # Redirect to yandexkassa
  #
  def redirect_to_yandexkassa_form_if_needed
    return unless params[:state] == "payment" or @order.payment?
    # TODO стоит ли делать так?
    payment_method = @order.payments.first.payment_method if @order.payments.any?
    payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id]) if payment_method.nil? and params[:order].present?
    if payment_method.kind_of? Spree::BillingIntegration::YandexkassaIntegration
      redirect_to yandexkassa_path(:gateway_id => payment_method.id, :order_id => @order.id)
    end

  end

end
