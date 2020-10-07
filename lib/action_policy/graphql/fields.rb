# frozen_string_literal: true

require "action_policy/graphql/types/authorization_result"

module ActionPolicy
  using RubyNext

  module GraphQL
    # Add DSL to add policy rules as fields
    #
    # Example:
    #
    #   class PostType < ::GraphQL::Schema::Object
    #     # Adds can_edit, can_destroy fields with
    #     # AuthorizationResult type.
    #
    #     expose_authorization_rules :edit?, :destroy?, prefix: "can_"
    #   end
    #
    # Prefix is "can_" by default.
    module Fields
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def expose_authorization_rules(*rules, field_name: nil, prefix: ::ActionPolicy::GraphQL.default_authorization_field_prefix, **options)
          raise ArgumentError, "Cannot specify field_name for multiple rules" if rules.size > 1 && !field_name.nil?

          rules.each do |rule|
            gql_field_name = field_name || "#{prefix}#{rule.to_s.delete("?")}"

            field gql_field_name,
              ActionPolicy::GraphQL::Types::AuthorizationResult,
              null: false

            define_method(gql_field_name) do
              allowance_to(rule, object, **options)
            end
          end
        end
      end
    end
  end
end
