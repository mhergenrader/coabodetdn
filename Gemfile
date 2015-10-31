source 'http://rubygems.org'

gem 'rails', '3.2.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

group :production do
  gem 'pg'
end
group :development, :test do
  gem 'sqlite3'
end

gem 'devise'
gem "cancan"
gem 'will_paginate'
gem 'recaptcha'

gem 'nokogiri'
gem 'fog'
#gem 'rmagick' # for heroku
gem 'mini_magick'
gem 'carrierwave'

gem 'rails3-jquery-autocomplete'
gem 'google_visualr'
gem 'googlecharts'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>=1.0.3'
end

gem 'jquery-rails'
#gem 'thinking-sphinx', '2.0.10'



# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'email_spec'
end