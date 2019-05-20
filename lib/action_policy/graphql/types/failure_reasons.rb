# frozen_string_literal: true

module ActionPolicy
  module GraphQL
    module Types
      class FailureReasons < ::GraphQL::Schema::Object
        field :details, String, null: false, description: "JSON-encoded map of reasons"
        field :full_messages, [String], null: false, description: "Human-readable errors"

        def details
          object.details.to_json
        end
      end
    end
  end
end
