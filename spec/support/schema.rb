# frozen_string_literal: true

class Post < Struct.new(:title); end

class PostList < Array
  def policy_name
    "#{first.class}Policy"
  end
end

class PostPolicy < ActionPolicy::Base
  scope_matcher :data, PostList

  scope_for :data do |data|
    next data if admin?

    data.select { |post| post.title.start_with? "public" }
  end

  pre_check :allow_admins

  def index?
    true
  end

  def view_secret_posts?
    # allow_admins pre-check allows admin access
    false
  end

  def create?
    true
  end

  def public?
    record.title.start_with?("public")
  end

  def show?
    record.title.end_with?("visible")
  end

  def manage?
    check?(:public?) && allowed_to?(:show?)
  end

  def secret_title?
    false
  end

  def silent_secret_title?
    false
  end

  private

  def allow_admins
    allow! if admin?
  end

  def admin?
    user == :admin
  end
end

class AnotherPostPolicy < PostPolicy
  def preview?
    public? && show?
  end

  def maybe_preview?
    # only admins can preview (controlled by pre-check)
    false
  end
end

I18n.backend = I18n::Backend::Simple.new.tap do |backend|
  backend.store_translations(
    :en,
    {
      action_policy: {
        policy: {
          post: {
            manage?: "You shall not do this",
            edit?: "Cannot edit post",
            show?: "Cannot show post",
            public?: "Post is not public"
          }
        }
      }
    }
  )
end

class BaseType < ::GraphQL::Schema::Object
  include ActionPolicy::GraphQL::Behaviour

  def current_user
    context.fetch(:user, :user)
  end
end

class BaseResolver < ::GraphQL::Schema::Resolver
  include ActionPolicy::GraphQL::Behaviour

  def current_user
    context.fetch(:user, :user)
  end
end

class PostType < BaseType
  field :title, String, null: false
  field :secret_title, String, null: false, authorize_field: true
  field :silent_secret_title, String, null: true, authorize_field: {raise: false}
  field :another_secret_title, String, null: true, authorize_field: {to: :preview?, with: AnotherPostPolicy}

  expose_authorization_rules :edit?, :show?, prefix: "can_"
  expose_authorization_rules :destroy?, prefix: "can_i_"

  def secret_title
    "Secret #{object.title}"
  end

  alias silent_secret_title secret_title
  alias another_secret_title secret_title
end

class PostConnectionWithTotalCountType < GraphQL::Types::Relay::BaseConnection
  edge_type(PostType.edge_type)

  field :total_count, Integer, null: false

  def total_count
    object.nodes.size
  end
end

class AuthorizedPostType < PostType
  def self.authorized?(object, context)
    super &&
      allowed_to?(
        :show?,
        object,
        context: {user: context[:current_user]}
      )
  end
end

module MyNamespace
  class PostPolicy < ::PostPolicy
    def show?
      true
    end
  end

  class PostType < ::AuthorizedPostType
    graphql_name "MyNamespacePost"
  end
end

# Namespaced types
module Me
  class << self
    attr_accessor :posts, :post
  end

  class PostPolicy < ::PostPolicy
    scope_for :data do |data|
      data.select { |post| post.title.match?(/\bmy\b/) }
    end

    def show?
      record.title.match?(/\bmy\b/)
    end
  end

  class PostType < BaseType
    graphql_name "MyPostType"

    field :title, String, null: false

    expose_authorization_rules :show?, prefix: "can_"

    def title
      "My #{object.title}"
    end
  end

  class RootType < BaseType
    field :bio, PostType, null: false, authorize: true
    field :posts, [PostType], null: false, authorized_scope: true
    field :all_posts, [PostType], null: false

    expose_authorization_rules :create?, with: PostPolicy, field_name: :can_create_post

    def bio
      Me.post
    end

    def posts
      Me.posts
    end

    alias all_posts posts
  end
end

class Schema < GraphQL::Schema
  class << self
    attr_accessor :posts, :post
  end

  class PostResolver < BaseResolver
    type PostType, null: false

    def resolve
      Schema.post.tap do |post|
        authorize! post, to: :show?
      end
    end
  end

  query(Class.new(BaseType) do
    def self.name
      "Query"
    end

    field :me, Me::RootType, null: false

    field :post, PostType, null: false
    field :authorized_post, AuthorizedPostType, null: true
    field :authorized_namespaced_post, MyNamespace::PostType, null: true
    field :resolved_post, resolver: PostResolver
    field :auth_post, PostType, null: false, authorize: true
    field :non_raising_post, PostType, null: true, authorize: {raise: false}
    field :secret_post, PostType, null: true, preauthorize: {with: AnotherPostPolicy, raise: false, to: :maybe_preview?}
    field :another_post, PostType, null: false, authorize: {to: :preview?, with: AnotherPostPolicy}
    field :posts, [PostType], null: false, authorized_scope: {type: :data, with: PostPolicy}
    field :all_posts, [PostType], null: false, preauthorize: {with: PostPolicy}
    field :secret_posts, [PostType], null: false, preauthorize: {to: :view_secret_posts?, with: PostPolicy}
    field :connected_posts, PostType.connection_type, null: false, authorized_scope: true
    field :another_connected_posts, PostConnectionWithTotalCountType, null: false, authorized_scope: true, connection: true

    def me
      {}
    end

    def post
      Schema.post
    end

    alias_method :authorized_post, :post
    alias_method :authorized_namespaced_post, :post
    alias_method :auth_post, :post
    alias_method :another_post, :post
    alias_method :non_raising_post, :post
    alias_method :secret_post, :post

    def posts
      Schema.posts
    end

    alias_method :secret_posts, :posts
    alias_method :all_posts, :posts
    alias_method :connected_posts, :posts
    alias_method :another_connected_posts, :posts
  end)
end
