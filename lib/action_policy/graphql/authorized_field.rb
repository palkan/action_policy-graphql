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

      class PreauthorizeExtension < ::GraphQL::Schema::FieldExtension
        def initialize(*)
          super
          if options[:with].nil?
            raise ArgumentError, "You must specify the policy for preauthorization: " \
                                 "`field :#{field.name}, preauthorize: {with: SomePolicy}`"
          end
          options[:to] ||=
            if field.type.list?
              ::ActionPolicy::GraphQL.default_preauthorize_list_rule
            else
              ::ActionPolicy::GraphQL.default_preauthorize_node_rule
            end
          options[:raise] = ::ActionPolicy::GraphQL.authorize_raise_exception unless options.key?(:raise)
        end

        def resolve(context:, object:, arguments:, **_rest)
          if options[:raise]
            object.authorize! field.name, **options
            yield object, arguments
          elsif object.allowed_to?(options[:to], field.name, options)
            yield object, arguments
          end
        end
      end

      class ScopeExtension < ::GraphQL::Schema::FieldExtension
        def after_resolve(value:, context:, object:, **_rest)
          return value if value.nil?

          object.authorized_scope(value, **options)
        end
      end

      def initialize(*args, preauthorize: nil, authorize: nil, authorized_scope: nil, **kwargs, &block)
        if authorize && authorized_scope
          raise ArgumentError, "Only one of `authorize` and `authorized_scope` " \
                               "options could be specified. You can use `preauthorize` along with scoping"
        end

        if authorize && preauthorize
          raise ArgumentError, "Only one of `authorize` and `preauthorize` " \
                               "options could be specified."
        end

        extensions = (kwargs[:extensions] ||= [])

        add_extension! extensions, AuthorizeExtension, authorize
        add_extension! extensions, ScopeExtension, authorized_scope
        add_extension! extensions, PreauthorizeExtension, preauthorize

        super(*args, **kwargs, &block)
      end

      private

      def add_extension!(extensions, extension_class, options)
        return unless options

        options = {} if options == true

        extension = {extension_class => options}

        if extensions.is_a?(Hash)
          extensions.merge!(extension)
        else
          extensions << extension
        end
      end
    end
  end
end
