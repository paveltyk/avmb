class WelcomeController < ApplicationController
  def index
    vendor_id = params[:id]
    if vendor_id.present?
      @blurb = Blurb.find_or_create_by_car(AvParser::Car.new vendor_id)
    end
  end

  def hide_ads
    session[:hide_ads] = true
    render nothing: true
  end
end
