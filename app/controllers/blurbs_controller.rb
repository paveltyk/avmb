class BlurbsController < ApplicationController
  expose(:id) { params[:short_id].present? ? Blurb.decode_short_id(params[:short_id]) : params[:id] }
  expose(:blurbs) do
    scope = Blurb.order_by(order.to_criteria).order_by(:vendor_id, :desc).page(params[:page]).per(25)

    if params[:phone]
      scope.where(phone: Blurb.deparameterize(params[:phone]))
    else
      scope.where(search.to_conditions)
    end
  end
  expose(:blurb) { Blurb.find(id) }
  expose(:blurb_decorator) { BlurbDecorator.new(blurb) }
  expose(:similar_blurbs) { Blurb.where(car_hash: blurb.car_hash, :_id.ne => blurb.id).order_by(:vendor_id, :desc) }
  expose(:blurbs_with_same_phone_count) { Blurb.where(phone: blurb.phone, :_id.ne => blurb.id).count }
end
