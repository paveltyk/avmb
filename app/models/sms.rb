class Sms
  include Mongoid::Document
  include Mongoid::Timestamps

  field :to, type: String
  field :body, type: String

  validates_presence_of :to, :body
  after_create :deliver

  def deliver
    if %w(production staging).include?(Rails.env)
      TwilioAgent::SMS.new(to: to, body: body).deliver
    else
      logger.debug "\n#{'*'*8}\nSMS delivery debug:\n\tTo:#{to}\n\tBody:#{body}\n#{'*'*8}\n"
    end

  end
end
