namespace :avmb do
  task :scrape => :environment do
    AvParser::Scrapper.new.perform
  end

  task :reload_images => :environment do
    AvParser::PhotoReprocessor.new(min_created_at: ENV['MIN_CREATED_AT'], max_created_at: ENV['MAX_CREATED_AT']).perform
  end

  task :reprocess_photos_to_v1 => :environment do
    aws_credentials = YAML.load_file(Photo.image_options[:s3_credentials])
    bucket_name = Photo.image_options[:bucket]
    AWS.config aws_credentials
    s3 = AWS::S3.new
    bucket = s3.buckets[bucket_name]
    if bucket.exists?
      Blurb.unscoped.where(:reprocessed_v1.ne => true).each do |blurb|
        puts "Processing blurb: #{blurb.id}"
        blurb.photos.each { |photo| photo.image.reprocess! }
        blurb.update_attribute :reprocessed_v1, true
      end

    else
      puts "Bucket with name #{bucket_name.inspect} not found."
    end
  end
end
