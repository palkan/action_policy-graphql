# frozen_string_literal: true

require "graphql"
require "action_policy"

require "action_policy/graphql/behaviour"

module ActionPolicy
  module GraphQL
    class << self
      # Which rule to use when no specified (e.g. `authorize: true`)
      # Defaults to `:show?`
      attr_accessor :default_authorize_rule

      # Whether to raise an exeption if field is not authorized
      # or return `nil`.
      # Defaults to `true`.
      attr_accessor :authorize_raise_exception

      # Which prefix to use for authorization fields
      # Defaults to `"can_"`
      attr_accessor :default_authorization_field_prefix
    end

    self.default_authorize_rule = :show?
    self.authorize_raise_exception = true
    self.default_authorization_field_prefix = "can_"
  end
end
