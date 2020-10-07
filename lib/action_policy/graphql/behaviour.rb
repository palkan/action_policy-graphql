# frozen_string_literal: true

require "action_policy/graphql/fields"
require "action_policy/graphql/authorized_field"

module ActionPolicy
  module GraphQL
    module Behaviour
      require "action_policy/ext/module_namespace"
      using ActionPolicy::Ext::ModuleNamespace

      # When used with self.authorized?
      def self.extended(base)
        base.extend ActionPolicy::Behaviour
        base.extend ActionPolicy::Behaviours::ThreadMemoized
        base.extend ActionPolicy::Behaviours::Memoized
        base.extend ActionPolicy::Behaviours::Namespaced

        # Authorization context could't be defined for the class
        def base.authorization_context
          {}
        end

        # Override authorization_namespace to use the class itself
        def base.authorization_namespace
          return @authorization_namespace if instance_variable_defined?(:@authorization_namespace)
          @authorization_namespace = namespace
        end
      end

      def self.included(base)
        base.include ActionPolicy::Behaviour
        base.include ActionPolicy::Behaviours::ThreadMemoized
        base.include ActionPolicy::Behaviours::Memoized
        base.include ActionPolicy::Behaviours::Namespaced

        base.authorize :user, through: :current_user

        if base.respond_to?(:field_class) && !(base.field_class < ActionPolicy::GraphQL::AuthorizedField)
          base.field_class.prepend(ActionPolicy::GraphQL::AuthorizedField)
          base.include ActionPolicy::GraphQL::Fields
        end

        base.extend self
      end

      def current_user
        context[:current_user]
      end
    end
  end
end
