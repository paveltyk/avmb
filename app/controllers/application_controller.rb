# encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :logged_in?, :hide_ads?
  expose(:search) { Search.new session[:search]}
  expose(:order) { Order.new params[:order]}

  private

  def current_user
    return nil if session[:user_id].blank?
    return @current_user if defined?(@current_user)
    @current_user = User.find(session[:user_id])
  end

  def logged_in?
    !!current_user
  end

  def require_user
    unless logged_in?
      store_location
      flash[:notice] = 'Авторизируйтесь'
      redirect_to login_path
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session.delete(:return_to) || default)
  end

  def reset_current_user
    remove_instance_variable(:@current_user) if defined?(@current_user)
  end

  def hide_ads?
    true
  end
end
