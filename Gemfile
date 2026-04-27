source "https://rubygems.org"

gem "dotenv-rails", "~> 3.2", groups: %i[development test]

gem "bootsnap", require: false
gem "mysql2", "~> 0.5"
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.3"
gem "tzinfo-data", platforms: %i[windows jruby]

# Auth
gem "bcrypt", "~> 3.1.7"
gem "jwt"

# API
gem "rack-cors"

# Tenancy
gem "acts_as_tenant"

# Serializer
gem "blueprinter"

# Pagination
gem "pagy"

# Authorization
gem "pundit"

# Background jobs
gem "sidekiq"

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "rubocop-rails-omakase", require: false
  gem "shoulda-matchers"
end

group :development do
  gem "bullet"
end
