# frozen_string_literal: true

module ActionPolicy
  module GraphQL
    # Add `authorized` option to the field
    #
    # Example:
    #
    #   class PostType < ::GraphQL::Schema::Object
    #     field :comments, null: false, authorized: true
    #
    #     # or with options
    #     field :comments, null: false, authorized: { type: :relation, with: MyPostPolicy }
    #   end
    module AuthorizedField
      class AuthorizeExtension < ::GraphQL::Schema::FieldExtension
        def initialize(*)
          super
          options[:to] ||= ::ActionPolicy::GraphQL.default_authorize_rule
          options[:raise] = ::ActionPolicy::GraphQL.authorize_raise_exception unless options.key?(:raise)
        end

        def after_resolve(value:, context:, object:, **_rest)
          return value if value.nil?

          if options[:raise]
            object.authorize! value, **options
            value
          else
            object.allowed_to?(options[:to], value, options) ? value : nil
          end
        end
      end

      class ScopeExtension < ::GraphQL::Schema::FieldExtension
        def after_resolve(value:, context:, object:, **_rest)
          return value if value.nil?

          object.authorized_scope(value, **options)
        end
      end

      def initialize(*args, authorize: nil, authorized_scope: nil, **kwargs, &block)
        if authorize && authorized_scope
          raise ArgumentError, "Only one of `authorize` and `authorized_scope` " \
                               "options could be specified"
        end

        options = authorize || authorized_scope

        if options
          options = {} if options == true

          extension_class = authorized_scope ? ScopeExtension : AuthorizeExtension

          extension = {extension_class => options}

          extensions = (kwargs[:extensions] ||= [])

          if extensions.is_a?(Hash)
            extensions.merge!(extension)
          else
            extensions << extension
          end
        end

        super(*args, **kwargs, &block)
      end
    end
  end
end
