class AvParser::Scrapper
  def perform
    puts "Scrapping..."

    ids = AvParser::List.new.ids.reverse
    puts "\tFound #{ids.size} items"

    ids.each do |id|
      if Blurb.unscoped.where(vendor_id: id).exists?
        puts "\tSkipping. Blurb with vendor_id #{id} exists"
        next
      else
        puts "\tCreating. Blurb with vendor_id #{id} seems to be new"
        car = AvParser::Car.new(id)
        blurb = Blurb.initialize_by_car(car)

        if blurb.save
          puts "\tSuccess"
          save_photos(blurb, car.images)
        else
          puts "\tFail. Errors: #{blurb.errors.full_messages.join(', ')}"
          blurb.published = false
          blurb.validating_errors = blurb.errors.full_messages
          blurb.save

          # Do not know why, but sometimes at first it fails to save published blurb, mostly with "Photos is invalid"error
          blurb.published = true
          blurb.save if blurb.valid?
        end
      end
    end

    puts "\tDone"
  end

  def save_photos(blurb, img_urls)
    img_urls.each do |img_path|
      photo = blurb.photos.build(image_download_url: img_path)
      result = photo.save
      puts "\t  Saving image: #{img_path} ... #{result ? 'OK' : 'Failed'}"
      errors = photo.errors.full_messages
      errors.each { |m| puts "\t  - #{m}" } if errors.present? && !result
    end
  end
end
