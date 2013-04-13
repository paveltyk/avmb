class AvParser::PhotoReprocessor
  attr_reader :options
  def initialize(options)
    raise 'Please specify at least MIN_CREATED_AT or MAX_CREATED_AT' if options[:min_created_at].blank? && options[:max_created_at].blank?

    @options = Hash.new.tap do |opts|
      puts opts[:min_created_at] = Time.parse(options[:min_created_at]) if options[:min_created_at]
      puts opts[:max_created_at] = Time.parse(options[:max_created_at]) if options[:max_created_at]
    end
  end

  def perform
    Blurb.where(options_for_criteria).order(:created_at, :asc).all.each do |blurb|
      puts "Reprocessing photos for blurb with vendor_id #{blurb.vendor_id} (created_at=#{blurb.created_at})..."
      if blurb.photos.present?
        puts "\tBlurb with vendor_id #{blurb.vendor_id} has photos. Next."
        next
      else
        car = AvParser::Car.new(blurb.vendor_id)
        save_photos(blurb, car.images)
      end
    end
  end

  private

  def save_photos(blurb, img_urls)
    puts "\tVendor has no photos." if img_urls.blank?
    img_urls.each do |img_path|
      photo = blurb.photos.build(image_download_url: img_path)
      result = photo.save
      puts "\tSaving image: #{img_path} ... #{result ? 'OK' : 'Failed'}"
      errors = photo.errors.full_messages
      errors.each { |m| puts "\t  - #{m}" } if errors.present? && !result
    end
  end

  def options_for_criteria
    Hash.new.tap do |res|
      res[:created_at.gte] = options[:min_created_at] if options[:min_created_at]
      res[:created_at.lte] = options[:max_created_at] if options[:max_created_at]
    end
  end
end
