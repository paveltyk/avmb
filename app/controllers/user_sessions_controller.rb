# encoding: utf-8
class UserSessionsController < ApplicationController
  def verify_code
    @user = User.find_or_initialize_by(phone: User.normalize_phone(params[:phone]))
    if @user.save
      @user.deliver_verification_code
    else
      render action: :new
    end
  end

  def create
    if @user = User.authenticate(params[:phone], params[:code])
      reset_current_user
      session[:user_id] = @user.id
      redirect_path = current_user.search_queries.present? ? my_search_queries_path : sms_notifications_path
      redirect_back_or_default redirect_path
    else
      flash[:error] = 'Не верный код верификации. Попробуйте снова.'
      redirect_to :action => :new
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to blurbs_path
  end
end
