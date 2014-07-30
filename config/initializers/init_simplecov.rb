if Rails.env.test?
  require 'simplecov'
  SimpleCov.start 'rails'
end
