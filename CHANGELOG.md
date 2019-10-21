# Change log

## master (unreleased)

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
