# encoding: utf-8
class Blurb
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :vendor_id, type: Integer
  field :name, type: String
  field :price_currency, type: String
  field :price_value, type: Integer
  field :year, type: Integer
  field :engine_value, type: Integer
  field :doors, type: Integer
  field :fuel_type, type: String
  field :color, type: String
  field :transmission, type: String
  field :drive_type, type: String
  field :body_type, type: String
  field :cylinders_count, type: String
  field :class_of_vehicle, type: String
  field :message, type: String
  field :phone, type: String
  field :published, type: Boolean, default: true
  field :parsing_errors, type: Array
  field :validating_errors, type: Array
  field :equipment, type: Array
  field :mileage_value, type: Integer
  field :mileage_units, type: String
  field :has_avatar, type: Boolean, default: false
  field :car_hash, type: String
  field :country, type: String
  field :city, type: String
  field :imported, type: Boolean, default: true
  field :reprocessed_v1, type: Boolean, default: false

  attr_accessible :name, :price_value, :year, :engine_value, :doors, :fuel_type, :color, :transmission,
                  :drive_type, :body_type, :cylinders_count, :mileage_value, :city, :country, :doors_count,
                  :photos_attributes

  index :phone
  index :car_hash
  index :deleted_at
  index [[:deleted_at, Mongo::DESCENDING], [:published, Mongo::DESCENDING], [:created_at, Mongo::DESCENDING], [:vendor_id, Mongo::DESCENDING]]

  embeds_many :photos, :inverse_of => :blurb, :cascade_callbacks => true
  accepts_nested_attributes_for :photos

  validates_presence_of :vendor_id, if: :imported?
  validates_presence_of :name, :price_currency, :price_value, :year, :engine_value, :doors, :fuel_type, :color,
                        :transmission, :drive_type, :body_type, :cylinders_count, :phone, if: :published?
  validates_uniqueness_of :vendor_id, if: 'published? && imported?'

  before_create lambda { |blurb| blurb.has_avatar = true}
  before_create lambda { |blurb| blurb.reprocessed_v1 = true}
  before_save :assign_car_hash
  after_create :create_missing_equipment_options
  after_create :clear_cache
  after_create :create_sms, if: :published?
  after_create lambda { Blurb.clear_cache }
  after_create :tweet, if: :post_tweet?

  default_scope where(published: true)

  def self.find_or_create_by_car(car)
    find_or_initialize_by_car(car).tap(&:save)
  end

  def self.find_or_initialize_by_car(car)
    where(vendor_id: car.id).first || initialize_by_car(car)
  end

  def self.initialize_by_car(car)
    BlurbBuilder.new(car).to_blurb
  end

  def has_photos?
    photos.present? && reprocessed_v1?
  end

  def self.distinct_car_names
    Rails.cache.fetch('car_name_autocomplete_source') { all.distinct(:name).delete_if(&:blank?) }
  end

  def self.distinct_cities
    Rails.cache.fetch('city_autocomplete_source', expires_in: 1.day) { all.distinct(:city).delete_if(&:blank?) }
  end

  def self.distinct_countries
    Rails.cache.fetch('country_autocomplete_source', expires_in: 1.day) { all.distinct(:country).delete_if(&:blank?) }
  end

  def self.distinct_fuel_types
    Rails.cache.fetch('fuel_type_autocomplete_source', expires_in: 1.day) { all.distinct(:fuel_type).delete_if(&:blank?) }
  end

  def self.distinct_body_types
    Rails.cache.fetch('body_type_autocomplete_source', expires_in: 1.day) { all.distinct(:body_type).delete_if(&:blank?) }
  end

  def self.distinct_body_colors
    Rails.cache.fetch('body_color_autocomplete_source1', expires_in: 1.day) { all.distinct(:color).delete_if(&:blank?) }
  end

  def self.distinct_transmission
    Rails.cache.fetch('transmission_autocomplete_source1', expires_in: 1.day) { all.distinct(:transmission).delete_if(&:blank?) }
  end

  def self.distinct_drive_types
    Rails.cache.fetch('drive_type_autocomplete_source', expires_in: 1.day) { all.distinct(:drive_type).delete_if(&:blank?) }
  end

  def self.stats
    Rails.cache.fetch 'car_count_stats', expires_in: 2.hours do
      only(:name).aggregate.sort { |a, b| b['count'] <=> a['count'] }
    end
  end

  def short_id
    self.class.encode_short_id(id)
  end

  def self.encode_short_id(id)
    id.to_s.hex.base62_encode
  end

  def self.decode_short_id(id)
    id.to_s.base62_decode.to_s(16)
  end

  def self.body_type_options
    Rails.cache.fetch(:body_types) { Blurb.all.distinct(:body_type).delete_if(&:blank?) }
  end

  def self.fuel_type_options
    Rails.cache.fetch(:fuel_types) { Blurb.all.distinct(:fuel_type).delete_if(&:blank?) }
  end

  def self.transmission_options
    Rails.cache.fetch(:transmissions) { Blurb.all.distinct(:transmission).delete_if(&:blank?) }
  end

  def self.clear_cache
    [:fuel_types, :body_types, :transmissions].each { |key| Rails.cache.delete(key) }
  end

  def self.deparameterize(phone)
    '+' + phone.to_s.gsub('-', ' ')
  end

  private

  def assign_car_hash
    str = [name, year, engine_value, doors, fuel_type, color, transmission, drive_type, body_type, cylinders_count, mileage_value, mileage_units].delete_if(&:blank?).join
    self.car_hash = Digest::MD5.hexdigest(str)
  end

  def decorator
    @decorator ||= BlurbDecorator.new(self)
  end

  def create_missing_equipment_options
    (equipment || []).each { |name| EquipmentOption.create name: name }
  end

  def clear_cache
    Rails.cache.delete('car_name_autocomplete_source')
  end

  def create_sms
    threads = []
    phones = []

    SearchQuery.all.each do |q|
      next unless q.to_search.match?(self) # Does counters cached? Do you think limit on Sms count can be exceeded here?

      if q.user.sms_credits_left? && !phones.include?(q.phone)
        phones << q.phone
        sms_body = "#{decorator.name} #{decorator.short_url}"

        threads << Thread.new(q.phone, sms_body) do |phone, sms_body|
          Sms.new(to: phone, body: sms_body).save and q.user.update_attribute(:last_blurb_sms_sent_at, Time.now)
        end
      end
    end

    threads.each(&:join)
  end

  def post_tweet?
    Rails.env.production? && published?
  end

  def tweet
    begin
      message = "Продам #{decorator.name} #{decorator.short_url} #авто #продам #беларусь #минск"
      Twitter.update(message)
      puts "Posted tweet: #{message}"
    rescue => e
      puts "Failed to post a tweet: #{e}"
    end
  end
end
