# frozen_string_literal: true

require "action_policy/graphql/fields"
require "action_policy/graphql/authorized_field"

module ActionPolicy
  module GraphQL
    module Behaviour
      def self.included(base)
        base.include ActionPolicy::Behaviour
        base.include ActionPolicy::Behaviours::ThreadMemoized
        base.include ActionPolicy::Behaviours::Memoized
        base.include ActionPolicy::Behaviours::Namespaced

        base.authorize :user, through: :current_user

        if base.respond_to?(:field_class)
          base.field_class.prepend(ActionPolicy::GraphQL::AuthorizedField)
          base.include ActionPolicy::GraphQL::Fields
        end
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
