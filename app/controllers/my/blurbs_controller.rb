# encoding: utf-8
class My::BlurbsController < ApplicationController
  before_filter :require_user
  expose(:blurbs) { Blurb.where(phone: current_user.format_phone) }
  expose(:blurb)

  def new
    6.times { blurb.photos.build }
  end


  def create
    blurb.published = true
    blurb.price_currency = '$'
    blurb.mileage_units = 'км.'
    blurb.phone = current_user.format_phone
    blurb.imported = false

    if blurb.save
      flash[:success] = 'Объявление сохранено и опубликовано!'
      redirect_to my_blurbs_path
    else
      blurb.photos.inject(0){|memo, _| memo+1}.upto(5) { blurb.photos.build }
      render :action => :new
    end
  end

  def destroy
    blurb.destroy
    flash[:success] = "Объявление удалено."
    redirect_to :action => :index
  end
end
