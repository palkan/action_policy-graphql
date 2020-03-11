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
      class Extension < ::GraphQL::Schema::FieldExtension
        def extract_option(key, &default)
          value = options.fetch(key, &default)
          options.delete key
          value
        end
      end

      class AuthorizeExtension < Extension
        def apply
          @to = extract_option(:to) { ::ActionPolicy::GraphQL.default_authorize_rule }
          @raise = extract_option(:raise) { ::ActionPolicy::GraphQL.authorize_raise_exception }
        end

        def after_resolve(value:, context:, object:, **_rest)
          return value if value.nil?

          if @raise
            object.authorize! value, to: @to, **options
            value
          else
            object.allowed_to?(@to, value, **options) ? value : nil
          end
        end
      end

      class PreauthorizeExtension < Extension
        def apply
          if options[:with].nil?
            raise ArgumentError, "You must specify the policy for preauthorization: " \
                                 "`field :#{field.name}, preauthorize: {with: SomePolicy}`"
          end

          @to = extract_option(:to) do
            if field.type.list?
              ::ActionPolicy::GraphQL.default_preauthorize_list_rule
            else
              ::ActionPolicy::GraphQL.default_preauthorize_node_rule
            end
          end

          @raise = extract_option(:raise) { ::ActionPolicy::GraphQL.authorize_raise_exception }
        end

        def resolve(context:, object:, arguments:, **_rest)
          if @raise
            object.authorize! field.name, to: @to, **options
            yield object, arguments
          elsif object.allowed_to?(@to, field.name, **options)
            yield object, arguments
          end
        end
      end

      class AuthorizeFieldExtension < Extension
        def apply
          @to = extract_option(:to) { underscored_field_name }
          @raise = extract_option(:raise) { ::ActionPolicy::GraphQL.authorize_raise_exception }
        end

        def resolve(context:, object:, arguments:, **_rest)
          if @raise
            object.authorize! object.object, to: @to, **options
            yield object, arguments
          elsif object.allowed_to?(@to, object.object, **options)
            yield object, arguments
          end
        end

        private

        def underscored_field_name
          "#{field.instance_variable_get(:@underscored_name)}?".to_sym
        end
      end

      class ScopeExtension < Extension
        def after_resolve(value:, context:, object:, **_rest)
          return value if value.nil?

          object.authorized_scope(value, **options)
        end
      end

      def initialize(*args, preauthorize: nil, authorize: nil, authorized_scope: nil, authorize_field: nil, **kwargs, &block)
        if authorize && authorized_scope
          raise ArgumentError, "Only one of `authorize` and `authorized_scope` " \
                               "options could be specified. You can use `preauthorize` or `authorize_field` along with scoping"
        end

        if !!authorize == !!preauthorize ? authorize : authorize_field
          raise ArgumentError, "Only one of `authorize`, `preauthorize` or `authorize_field` " \
                               "options could be specified."
        end

        extensions = (kwargs[:extensions] ||= [])

        add_extension! extensions, AuthorizeExtension, authorize
        add_extension! extensions, ScopeExtension, authorized_scope
        add_extension! extensions, PreauthorizeExtension, preauthorize
        add_extension! extensions, AuthorizeFieldExtension, authorize_field

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
