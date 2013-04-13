class SearchController < ApplicationController
  def update
    session[:search] = Search.new(params[:search]).to_param
    redirect_to params[:redirect_to].presence || blurbs_path
  end
end
