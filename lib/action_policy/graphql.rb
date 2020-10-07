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

      # Which rule to use when no specified for preauthorization (e.g. `preauthorize: true`)
      # of a list-like field.
      # Defaults to `:index?`
      attr_accessor :default_preauthorize_list_rule

      # Which rule to use when no specified for preauthorization (e.g. `preauthorize: true`)
      # of a singleton-like field.
      # Defaults to `:show?`
      attr_accessor :default_preauthorize_node_rule

      # Whether to raise an exeption if field is not authorized
      # or return `nil`.
      # Defaults to `true`.
      attr_accessor :authorize_raise_exception

      # Which prefix to use for authorization fields
      # Defaults to `"can_"`
      attr_accessor :default_authorization_field_prefix

      attr_writer :preauthorize_raise_exception

      # Whether to raise an exception if preauthorization fails
      # Equals to authorize_raise_exception unless explicitly set
      def preauthorize_raise_exception
        return authorize_raise_exception if @preauthorize_raise_exception.nil?
        @preauthorize_raise_exception
      end

      # Whether to raise an exception if preauthorization fails
      # Equals to preauthorize_raise_exception unless explicitly set
      attr_writer :preauthorize_mutation_raise_exception

      def preauthorize_mutation_raise_exception
        return preauthorize_raise_exception if @preauthorize_mutation_raise_exception.nil?

        @preauthorize_mutation_raise_exception
      end
    end

    self.default_authorize_rule = :show?
    self.default_preauthorize_list_rule = :index?
    self.default_preauthorize_node_rule = :show?
    self.authorize_raise_exception = true
    self.preauthorize_raise_exception = nil
    self.preauthorize_mutation_raise_exception = nil
    self.default_authorization_field_prefix = "can_"
  end
end
