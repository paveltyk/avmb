# encoding: utf-8
class PhoneSearchesController < ApplicationController
  def create
    if params[:phone_number].present?
      redirect_to blurbs_with_phone_path(params[:phone_number].parameterize)
    else
      flash['error'] = 'Введите номер телефона в формате +375-XX-XXX-XX-XX'
      redirect_to :back
    end
  end
end
