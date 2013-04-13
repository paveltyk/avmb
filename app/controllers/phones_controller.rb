# encoding: utf-8
class PhonesController < ApplicationController
  def send_verification_code
    @user = User.find_or_initialize_by(phone: User.normalize_phone(params[:phone]))
    @user.deliver_verification_code if @user.save

    respond_to do |format|
      format.js
    end
  end

  def verify_and_subscribe
    #TODO: Use User.authenticate
    @user = User.where(phone: User.normalize_phone(params[:phone]), verification_code: params[:code].to_s.downcase).first

    if @user
      if @user.search_queries.count >= @user.search_queries_limit
        flash.now[:warning] = "Извините, но лимит фильтров привязанных к Вашему номеру телефона исчерпан."
        render template: 'sms_notifications/step2'
      else
        @user.subscribe!(search)
        redirect_to sms_notification_step3_path(phone: @user.phone)
      end
    else
      flash.now[:warning] = 'Не верный код! Попробуйте снова.'
      render template: 'sms_notifications/step2'
    end
  end

  def payment
    phone = "+#{params[:user_id].to_s.gsub(/[^\d]/, '')}"
    @user = User.find_or_initialize_by(phone: User.normalize_phone(phone))

    SmsPayment.create(phone: phone, data: params.except.except(:controller, :action))

    if @user.save
      @user.update_attribute(:sms_deliveries_left, 0) if @user.sms_deliveries_left < 0
      @user.inc(:sms_deliveries_left, 5)
      render text: "SMS avmb.by Ура! Вам +5 СМС. Всего осталось #{@user.sms_deliveries_left} СМС."
    else
      render text: "SMS avmb.by Ошибка. Свяжитесь с support@avmb.by"
    end
  end
end
