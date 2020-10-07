# Change log

## master (unreleased)

- Add `preauthorize_mutation_raise_exception` configuration parameter. ([@palkan][])

Similar to `preauthorize_raise_exception` but only for mutations.
Fallbacks to `preauthorize_raise_exception` unless explicitly specified.

- Add `preauthorize_raise_exception` configuration parameter. ([@palkan][])

Similar to `authorize_raise_exception` but for `preauthorize: true` fields.
Fallbacks to `authorize_raise_exception` unless explicitly specified.

- Add ability to specify custom field options for `expose_authorization_rules`. ([@bibendi][])

Now you can add additional options for underflying `field` call via `field_options` parameter:

```ruby
expose_authorization_rules :show?, field_options: {camelize: false}

# equals to
field :can_show, ActionPolicy::GraphQL::Types::AuthorizationResult, null: false, camelize: false
```

## 0.4.0 (2010-03-11)

- **Require Ruby 2.5+**. ([@palkan][])

- Add `authorized_field: *` option to perform authorization on the base of the upper object policy prior to resolving fields. ([@sponomarev][])

## 0.3.2 (2019-12-12)

- Fix compatibility with Action Policy 0.4.0 ([@haines][])

## 0.3.1 (2019-10-23)

- Add support for using Action Policy methods in `self.authorized?`. ([@palkan][])

## 0.3.0 (2019-10-21)

- Add `preauthorize: *` option to perform authorization prior to resolving fields. ([@palkan][])

## 0.2.0 (2019-08-15)

- Add ability to specify a field name explicitly. ([@palkan][])

Now you can write, for example:

```ruby
expose_authorization_rules :create?, with: PostPolicy, field_name: :can_create_post
```

- Add support for resolvers. ([@palkan][])

Now it's possible to `include ActionPolicy::GraphQL::Behaviour` into resolver class to use
Action Policy helpers there.

## 0.1.0 (2019-05-20)

- Initial version. ([@palkan][])

[@palkan]: https://github.com/palkan
[@haines]: https://github.com/haines
[@sponomarev]: https://github.com/sponomarev
[@bibendi]: https://github.com/bibendi
