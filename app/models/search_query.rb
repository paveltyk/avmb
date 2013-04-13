class SearchQuery
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :start_year, type: Integer
  field :end_year, type: Integer
  field :start_price, type: Integer
  field :end_price, type: Integer
  field :fuel_type, type: String
  field :transmission, type: String
  field :start_engine_value, type: Integer
  field :end_engine_value, type: Integer
  field :equipment, type: Array
  field :body_type, type: String

  delegate :phone, to: :user

  belongs_to :user, inverse_of: :search_queries
  validates_presence_of :user

  def to_search
    Search.new(attributes)
  end
end
