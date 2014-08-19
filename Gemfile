source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 4.0.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3', group: [:development, :test, :production]
#gem 'mysql', group: :development

gem 'simplecov', group: :test
gem 'coveralls', require: false

# Use postgres for staging
gem 'pg', :group => :staging
gem 'rails_12factor', group: :staging

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
gem 'multi_json', '1.7.8'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby'

# Use LDAP for authentication
gem 'net-ldap'

# Use unicorn as the app server
gem 'unicorn', group: :staging

# Haml support!
gem 'haml-rails'

# Use Capistrano for deployment
group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
end

# Use debugger
#gem 'debugger', group: [:development, :test]
