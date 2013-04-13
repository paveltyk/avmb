class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  attr_accessor :image_download_url

  embedded_in :blurb, inverse_of: :photos

  def self.image_options
    opts = {:styles => { medium: ['560x560#', :jpg], small: ['44x44#', :jpg] },
            :url => '/system/:class/:attachment/:id_partition/:style.:extension'}
    bucket = "av-mobile-#{Rails.env}"
    s3_credentials = Rails.root.join('config', 'amazon_s3.yml')
    opts.merge!(:storage => :s3, :bucket => bucket, :s3_credentials => s3_credentials) if %w(production staging).include?(Rails.env)

    opts
  end

  has_mongoid_attached_file :image, image_options

  validates :image, attachment_size: {in: 1..5.megabytes},
                    attachment_content_type: {content_type: /image/i},
                    attachment_presence: true

  validates :blurb, presence: true

  before_validation :download_remote_image, :on => :create, :if => "image_download_url.present?"

  private

  def download_remote_image
    return if self.image_file_name.present?
    begin
      Timeout::timeout(8) do
        io = open URI.parse(image_download_url)
        def io.original_filename; base_uri.path.split('/').last.scan(/([\w\.]*\.(?:png|jpe?g|gif|bmp))/i).flatten.first; end
        self.image = io.original_filename.blank? ? nil : io
      end
    rescue Exception => e
      errors.add(:image_download_url, "Failed to download image from \"#{image_download_url}\": #{e.message}")
    end
  end
end
