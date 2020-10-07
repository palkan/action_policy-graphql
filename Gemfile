source "https://rubygems.org"

# Specify your gem's dependencies in action_policy-graphql.gemspec
gemspec

gem "pry-byebug", platform: :mri

eval_gemfile "gemfiles/rubocop.gemfile"

local_gemfile = File.join(__dir__, "Gemfile.local")

if File.exist?(local_gemfile)
  # Specify custom action_policy/graphql-ruby version in Gemfile.local
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
else
  gem "action_policy", ">= 0.5.0"
  gem "graphql", ">= 1.9.3"
end
