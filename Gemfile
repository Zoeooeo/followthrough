source "https://rubygems.org"

gem "rails", "~> 7.2.2"
gem "puma", ">= 5.0"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "sqlite3", ">= 1.4"
  gem "rspec-rails", "~> 7.0"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
end

group :test do
  gem "cucumber-rails", "~> 3.0", require: false
  gem "database_cleaner-active_record"
  gem "capybara"
  gem "simplecov", require: false
end

group :production do
  gem "pg", "~> 1.5"
end
