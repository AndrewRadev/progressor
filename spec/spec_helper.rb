require 'pp'
require 'bundler/setup'
require 'timecop'
require 'progressor'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  Timecop.safe_mode = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
