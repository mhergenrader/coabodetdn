# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Tdn::Application.initialize!
ENV['RAILS_ENV'] ||= 'production'
## Rails 1.2 - 2.0: environment.rb
require 'will_paginate'

require 'mini_magick'
