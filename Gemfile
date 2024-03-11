# frozen_string_literal: true

source "https://rubygems.org"

gem "i18n-js", "4.0"
gem "rails", "~> 7.1"
gem "rails-i18n", "~> 7.0"

gem "cssbundling-rails", "~> 1.4"
gem "jsbundling-rails", "~> 1.3"
gem "sassc-rails"
gem "sprockets", "~> 4.2"
gem "sprockets-rails", require: "sprockets/railtie"

gem "pg"

gem "turbo-rails"

gem "bcrypt", "~> 3.1.20"

gem "active_model_otp"
gem "bootsnap", require: false
gem "bootstrap_form", "~> 5.0"
gem "carrierwave", "~> 2.1"
gem "carrierwave_backgrounder", "~> 0.4.2"
gem "colorize"
gem "devise", "~> 4.9"
gem "devise-async"
gem "devise-i18n"
gem "fog-aws"
gem "fog-core"
gem "fog-local"
gem "haml", "~> 6.3"
gem "hcaptcha", git: "https://github.com/retrospring/hcaptcha", ref: "fix/flash-in-turbo-streams"
gem "mini_magick"
gem "oj"
gem "rpush"
gem "rqrcode"
gem "web-push"

gem "rolify", "~> 6.0"

gem "dry-initializer", "~> 3.1"
gem "dry-types", "~> 1.7"

gem "pghero"
gem "rails_admin"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"

gem "sidekiq", "< 7" # remove version constraint once are ready to upgrade https://github.com/mperham/sidekiq/blob/main/docs/7.0-Upgrade.md
gem "sidekiq-scheduler"

gem "questiongenerator", "~> 1.1"

gem "httparty"
gem "redcarpet"
gem "sanitize"

gem "twitter-text"

gem "connection_pool"
gem "redis"

gem "fake_email_validator"

# TLD validation
gem "tldv", "~> 0.1.0"

gem "view_component"

gem "jwt", "~> 2.8"

group :development do
  gem "binding_of_caller"
end

gem "puma"

group :development, :test do
  gem "better_errors"
  gem "bullet"
  gem "database_cleaner"
  gem "dotenv-rails", "~> 3.1"
  gem "factory_bot_rails", require: false
  gem "faker"
  gem "haml_lint", require: false
  gem "json-schema"
  gem "letter_opener" # Use this just in local test environments
  gem "rails-controller-testing"
  gem "rake"
  gem "rspec-its", "~> 1.3"
  gem "rspec-mocks"
  gem "rspec-rails", "~> 6.1"
  gem "rspec-sidekiq", "~> 4.1", require: false
  gem "rubocop", "~> 1.62"
  gem "rubocop-rails", "~> 2.24"
  gem "shoulda-matchers", "~> 6.1"
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "simplecov-json", require: false
end

group :production do
  gem "lograge"
end

gem "net-imap"
gem "net-pop"
gem "net-smtp"

gem "pundit", "~> 2.3"

gem "rubyzip", "~> 2.3"

# to solve https://github.com/jwt/ruby-jwt/issues/526
gem "openssl", "~> 3.2"

# mail 2.8.0 breaks sendmail usage: https://github.com/mikel/mail/issues/1538
gem "mail", "~> 2.7.1"

gem "prometheus-client", "~> 4.2"
