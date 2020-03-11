# Change log

## master (unreleased)

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
