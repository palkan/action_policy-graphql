# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "action_policy/graphql/version"

Gem::Specification.new do |spec|
  spec.name          = "action_policy-graphql"
  spec.version       = ActionPolicy::GraphQL::VERSION
  spec.authors       = ["Vladimir Dementyev"]
  spec.email         = ["dementiev.vm@gmail.com"]

  spec.summary       = "Action Policy integration for GraphQL-Ruby"
  spec.description   = "Action Policy integration for GraphQL-Ruby"
  spec.homepage      = "https://github.com/palkan/action_policy-graphql"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/palkan/action_policy-graphql/issues",
    "changelog_uri" => "https://github.com/palkan/action_policy-graphql/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://actionpolicy.evilmartians.io/#/graphql",
    "homepage_uri" => "https://github.com/palkan/action_policy-graphql",
    "source_code_uri" => "https://github.com/palkan/action_policy-graphql"
  }

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency "action_policy", ">= 0.3.0"
  spec.add_dependency "graphql", ">= 1.9.3"

  spec.add_development_dependency "bundler", ">= 1.15"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rubocop", "~> 0.67.0"
  spec.add_development_dependency "rubocop-md", "~> 0.3"
  spec.add_development_dependency "standard", "~> 0.0.39"
  spec.add_development_dependency "i18n"
end
