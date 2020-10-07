# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# This turns off per-thread caching in action_policy
ENV["RACK_ENV"] = "test"

require "i18n"
require "action_policy-graphql"
begin
  require "pry-byebug"
rescue LoadError
end

require "action_policy/rspec"

ActionPolicy::GraphQL.preauthorize_raise_exception = false
ActionPolicy::GraphQL.preauthorize_mutation_raise_exception = true

Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed
end
