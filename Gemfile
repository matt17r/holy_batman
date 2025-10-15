source "https://rubygems.org"

gem "rails", github: "rails/rails", branch: "main"

gem "bootsnap", require: false
gem "importmap-rails"
gem "jbuilder"
gem "kamal", require: false
gem "propshaft"
gem "puma"
gem "solid_cache"
gem "sqlite3"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "thruster", require: false
gem "turbo-rails"

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
