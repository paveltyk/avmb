class Admin::ArticlesController < ApplicationController
  expose(:articles) { Article.all }
  expose(:article)

  def create
    if article.save
      flash.notice = 'Article successfully saved!'
      redirect_to [:admin, article]
    else
      render action: :new
    end
  end

  def edit
    render action: :new
  end

  def update
    if article.save
      flash.notice = 'Article successfully updated!'
      redirect_to [:admin, article]
    else
      render action: :new
    end
  end
end
