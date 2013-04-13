# encoding: utf-8
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :phone, type: String
  field :verification_code, type: String
  field :verification_code_sent_at, type: Time
  field :sms_deliveries_left, type: Integer, default: 5
  field :search_queries_limit, type: Integer, default: 1
  field :last_blurb_sms_sent_at, type: Time

  validates_format_of :phone, with: /^\+375\d{9}$/

  has_many :search_queries, dependent: :destroy

  before_validation :normalize_phone

  def deliver_verification_code
    generate_verification_code

    if Sms.new(to: phone, body: "\"#{verification_code}\" - код верификации для avmb.by").save
      update_attribute(:verification_code_sent_at, Time.now)
    end
  end

  def self.authenticate(phone, code)
    user = where(phone: normalize_phone(phone), verification_code: code.to_s.downcase).first
    user.update_attribute(:verification_code, nil) if user

    user
  end

  def self.normalize_phone(phone)
    phone.gsub(/[^\+\d]/, '') if phone
  end

  def subscribe!(search)
    update_attribute(:verification_code, nil)
    search_queries.create(search.to_param)
  end

  def sms_credits_left?
    last_blurb_sms_sent_at.nil? || (last_blurb_sms_sent_at && last_blurb_sms_sent_at < 1.day.ago)
  end

  def format_phone
    chars = phone.to_s.mb_chars
    @format_phone ||= [chars[0..3], chars[4..5], chars[6..8], chars[9..10], chars[11..12]].join(' ')
  end

  private

  def normalize_phone
    self.phone = User.normalize_phone(phone)
  end

  def generate_verification_code
    self.verification_code = ('a'..'z').to_a.sample(4).join
  end
end
