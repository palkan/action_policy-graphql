# frozen_string_literal: true

require "action_policy/graphql/types/failure_reasons"

module ActionPolicy
  module GraphQL
    module Types
      class AuthorizationResult < ::GraphQL::Schema::Object
        field :value, Boolean, null: false, description: "Result of applying a policy rule"
        field :message, String, null: true, description: "Human-readable error message"
        field :reasons, FailureReasons, null: true, description: "Reasons of check failure"

        def message
          return if object.value == true
          object.message
        end

        def reasons
          return if object.value == true
          object.reasons
        end
      end
    end
  end
end
