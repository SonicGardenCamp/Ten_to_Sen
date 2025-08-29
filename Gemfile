source "https://rubygems.org"

gem "rails", "~> 8.0.2", ">= 8.0.2.1"

gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem "rspec-rails"

# gem "jbuilder" # API形式ではレスポンス返さないので不要
# gem "bcrypt", "~> 3.1.7"

gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
# gem "image_processing", "~> 1.2"

gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
end

group :development do
  gem "web-console"
  gem "better_errors"
  gem "binding_of_caller"
end
