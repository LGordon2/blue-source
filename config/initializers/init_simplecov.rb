if Rails.env.test?
  require 'simplecov'
  SimpleCov.start 'rails'
  puts "required simplecov"
end