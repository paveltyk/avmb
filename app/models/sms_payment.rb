class SmsPayment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :phone, type: String
  field :data, type: Hash
end
