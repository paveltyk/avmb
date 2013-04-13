class Article
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :body, type: String

  validates_presence_of :title, :body

  def to_html
    RDiscount.new(body.to_s).to_html.html_safe
  end
end
