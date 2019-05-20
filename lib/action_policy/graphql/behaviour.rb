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

        base.field_class.prepend(ActionPolicy::GraphQL::AuthorizedField)
        base.authorize :user, through: :current_user

        base.include ActionPolicy::GraphQL::Fields
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
