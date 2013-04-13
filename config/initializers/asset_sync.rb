if defined?(AssetSync)
  AssetSync.configure do |config|
    amazon_s3 = YAML.load_file(Rails.root.join 'config', 'amazon_s3.yml')
  
    config.fog_provider = 'AWS'
    config.aws_access_key_id = amazon_s3['access_key_id']
    config.aws_secret_access_key = amazon_s3['secret_access_key']
    config.fog_directory = "av-mobile-#{Rails.env}"
    
    # Increase upload performance by configuring your region
    # config.fog_region = 'eu-west-1'
    #
    # Don't delete files from the store
    # config.existing_remote_files = "keep"
    #
    # Automatically replace files with their equivalent gzip compressed version
    # config.gzip_compression = true
    #
    # Use the Rails generated 'manifest.yml' file to produce the list of files to 
    # upload instead of searching the assets directory.
    # config.manifest = true
    #
    # Fail silently.  Useful for environments such as Heroku
    config.fail_silently = true
  end
end