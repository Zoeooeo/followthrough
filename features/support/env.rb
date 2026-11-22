require "simplecov"

require "cucumber/rails"

ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner-active_record to your Gemfile (in the :test group) to use it."
end

Cucumber::Rails::Database.javascript_strategy = :truncation

require Rails.root.join("spec/support/test_data")
World(TestData)
World(ActionView::RecordIdentifier)
