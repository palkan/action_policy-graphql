[![Gem Version](https://badge.fury.io/rb/action_policy-graphql.svg)](https://badge.fury.io/rb/action_policy-graphql)
[![Build Status](https://travis-ci.org/palkan/action_policy-graphql.svg?branch=master)](https://travis-ci.org/palkan/action_policy-graphql)
[![Documentation](https://img.shields.io/badge/docs-link-brightgreen.svg)](https://actionpolicy.evilmartians.io/#/graphql)

# Action Policy GraphQL

This gem provides an integration for using [Action Policy](https://github.com/palkan/action_policy) as an authorization framework for GraphQL applications (built with [`graphql` ruby gem](https://graphql-ruby.org)).

This integration includes the following features:
- Fields & mutations authorization
- List and connections scoping
- **Exposing permissions/authorization rules in the API**.

📑 [Documentation](https://actionpolicy.evilmartians.io/#/graphql)

<a href="https://evilmartians.com/?utm_source=action_policy-graphql">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

Add this line to your application's Gemfile:

```ruby
gem "action_policy-graphql", "~> 0.1"
```

And then execute:

    $ bundle

## Usage

**NOTE:** this is a quick overview of the functionality provided by the gem. For more information see the [documentation](https://actionpolicy.evilmartians.io/#/graphql).

To start using Action Policy in GraphQL-related code you need to enhance your base classes with `ActionPolicy::GraphQL::Behaviour`:

```ruby
# For fields authorization, lists scoping and rules exposing
class Types::BaseObject < GraphQL::Schema::Object
  include ActionPolicy::GraphQL::Behaviour
end

# For using authorization helpers in mutations
class Types::BaseMutation < GraphQL::Schema::Mutation
  include ActionPolicy::GraphQL::Behaviour
end
```

### `authorize: *`

You can add authorization to the fields by specifying the `authorize: *` option:

```
field :home, Home, null: false, authorize: true do
  argument :id, ID, required: true
end

# field resolver method
def home(id:)
  Home.find(id)
end
```

The code above is equal to:

```ruby
field :home, Home, null: false do
  argument :id, ID, required: true
end

def home(id:)
  Home.find(id).tap { |home| authorize! home, to: :show? }
end
```

You can customize the authorization options, e.g. `authorize: {to: :preview?, with: CustomPolicy}`.

### `authorized_scope`

You can add `authorized_scope: true` option to the field (list or _connection_ field) to
apply the corresponding policy rules to the data:

```ruby
class CityType < ::Common::Graphql::Type
  # It would automatically apply the relation scope from the EventPolicy to
  # the relation (city.events)
  field :events, EventType.connection_type, null: false, authorized_scope: true

  # you can specify the policy explicitly
  field :events, EventType.connection_type, null: false, authorized_scope: {with: CustomEventPolicy}
end
```

### `expose_authorization_rules`

You can add permissions/authorization exposing fields to "tell" clients which actions could be performed against the object or not (and why).

For example:

```ruby
class ProfileType < ::Common::Graphql::Type
  # Adds can_edit, can_destroy fields with
  # AuthorizationResult type.

  # NOTE: prefix "can_" is used by default, no need to specify it explicitly
  expose_authorization_rules :edit?, :destroy?, prefix: "can_"
end
```

Then the client could perform the following query:

```gql
{
  post(id: $id) {
    canEdit {
      # (bool) true|false; not null
      value
      # top-level decline message ("Not authorized" by default); null if value is true
      message
      # detailed information about the decline reasons; null if value is true
      reasons {
        details # JSON-encoded hash of the form { "community/event" => [:privacy_off?] }
        fullMessages # Array of human-readable reasons
      }
    }

    canDestroy {
      # ...
    }
  }
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/action_policy-graphql.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
