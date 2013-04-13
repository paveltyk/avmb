class MySearchQueriesController < ApplicationController
  before_filter :require_user
  expose(:search_queries) { current_user.search_queries }
  expose(:search_query)

  def destroy
    search_query.destroy rescue nil
    redirect_to :action => :index
  end
end
