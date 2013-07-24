### Chef Server
#
# KNIFE_CHEF_SERVER             - the URL for the Chef Server
# KNIFE_VALIDATION_CLIENT_NAME  - validation client name, default is
#                                 'chef-validator'
#
chef_dir    = "#{ENV['HOME'] || ENV['HOMEDRIVE']}/.chef"
current_dir = File.dirname(__FILE__)

# chef server location and validation key
chef_server_url           ENV['KNIFE_CHEF_SERVER_URL']
validation_client_name    ENV['KNIFE_VALIDATION_CLIENT_NAME'] ||
                          'chef-validator'
validation_key            ENV['KNIFE_VALIDATION_KEY'] ||
                          "#{chef_dir}/validation.pem"

# user/client name and key
node_name                 (ENV['KNIFE_USER'] || ENV['USER'] ||
                           ENV['USERNAME']).downcase
client_key                ENV['KNIFE_CLIENT_KEY'] ||
                          "#{chef_dir}/#{node_name}.pem"

# path to cookbooks
cookbook_path             ["#{File.dirname(__FILE__)}/../cookbooks"]

# logging details
log_level                 :info
log_location              STDOUT

# caching options
cache_type                'BasicFile'
cache_options( :path =>   "#{chef_dir}/checksums" )

file_backup_path          "#{chef_dir}/backups"

# new cookbook defaults
cookbook_copyright        ENV['KNIFE_COOKBOOK_COPYRIGHT'] ||
                          %x{git config --get user.name}.chomp
cookbook_email            ENV['KNIFE_COOKBOOK_EMAIL'] ||
                          %x{git config --get user.email}.chomp
cookbook_license          'apachev2'

# aws ec2 configuration
if ENV['AWS_AWS_ACCESS_KEY_ID'] && ENV['AWS_AWS_SECRET_ACCESS_KEY']
  ##
  # Searches the ENV hash for keys starting with "AWS_" and converts them
  # to knife config settings. For example:
  #
  #     ENV['AWS_ACCESS_KEY_ID'] = "abcabc"
  #     ENV['AWS_FLAVOR'] = "t1.small"
  #
  # becomes:
  #
  #     knife[:access_key_id] = "abcabc"
  #     knife[:flavor] = "t1.small"
  aws_attrs = ENV.keys.select { |k| k =~ /^AWS_/ }

  aws_attrs.each do |key|
    knife.send(:[]=, key.sub(/^AWS_/, '').downcase.to_sym, ENV[key])
  end
end

# bluebox configuration
if ENV['BLUEBOX_CUSTOMER_ID'] && ENV['BLUEBOX_API_KEY']
  knife[:bluebox_customer_id] = ENV['BLUEBOX_CUSTOMER_ID']
  knife[:bluebox_api_key]     = ENV['BLUEBOX_API_KEY']
end

# rackspace configuration
if ENV['RACKSPACE_USERNAME'] && ENV['RACKSPACE_API_KEY']
  knife[:rackspace_api_username]  = ENV['RACKSPACE_USERNAME']
  knife[:rackspace_api_key]       = ENV['RACKSPACE_API_KEY']
end

# allow overriding values in this knife.rb
if ENV['KNIFE_OVERRIDE'] && File.exist?(ENV['KNIFE_OVERRIDE'])
  Chef::Config.from_file(ENV['KNIFE_OVERRIDE'])
end
