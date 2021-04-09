# Argon2 - Ruby Wrapper

Forked from [technion/ruby-argon2](https://github.com/technion/ruby-argon2) aka
the `argon2` gem, `v2.0.3`. See below for a migration guide if you would like to
move an existing application from `argon2` to `sorcery-argon2`.

[Why was `argon2` forked?](https://github.com/technion/ruby-argon2/pull/44#issuecomment-816271661)

## Table of Contents

1. [Useful Links](#useful-links)
2. [API Summary](#api-summary)
3. [Installation](#installation)
4. [Migrating from `argon2` to `sorcery-argon2`](#migrating-from-argon2-to-sorcery-argon2)
5. [Contributing](#contributing)
6. [Contact](#contact)
7. [License](#license)

## Useful Links

* [Documentation](https://rubydoc.info/gems/sorcery-argon2)

## API Summary

Below is a summary of the library methods. Most method names are self explaining
and the rest are commented:

### Argon2::Password

```ruby
# Class methods
Argon2::Password.create(password, options = {})
Argon2::Password.valid_hash?(digest)
Argon2::Password.verify_password(password, digest, pepper = nil)

# Instance Methods
argon2 = Argon2::Password.new(digest)
argon2 == other_argon2
argon2.matches?(password, pepper = nil)
argon2.to_s   # Returns the digest as a String
argon2.to_str # Also returns the digest as a String

# Argon2::Password Attributes (readonly)
argon2.digest
argon2.variant
argon2.version
argon2.t_cost
argon2.m_cost
argon2.p_cost
argon2.salt
argon2.checksum
```

### Errors

```ruby
Argon2::Error
Argon2::Errors::InvalidHash
Argon2::Errors::InvalidVersion
Argon2::Errors::InvalidCost
Argon2::Errors::InvalidTCost
Argon2::Errors::InvalidMCost
Argon2::Errors::InvalidPCost
Argon2::Errors::InvalidPassword
Argon2::Errors::InvalidSaltSize
Argon2::Errors::InvalidOutputLength
Argon2::Errors::ExtError
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sorcery-argon2'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install sorcery-argon2
```

Require Sorcery-Argon2 in your project:

```ruby
require 'argon2'
```

### Using RubyGems MediumSecurity

`sorcery-argon2` is cryptographically signed. To be sure the gem you install
hasn't been tampered with:

Add my public key (if you haven't already) as a trusted certificate:

```
gem cert --add <(curl -Ls https://raw.github.com/Sorcery/argon2/master/certs/athix.pem)

gem install sorcery-argon2 -P MediumSecurity
```

The MediumSecurity trust profile will verify signed gems, but allow the
installation of unsigned dependencies.

This is necessary because `ffi` is not currently signed, meaning we cannot use
HighSecurity.

## Migrating from `argon2` to `sorcery-argon2`

There are two primary changes going from `argon2` to `sorcery-argon2`:

### The Argon2::Password API has been refactored

**Argon2::Password.new and Argon2::Password.create are now different.**

Argon2::Passwords can now be created without initializing an instance first.

To upgrade:

```ruby
# Take instances where you abstract creating the password by first exposing an
# Object instance:
instance = Argon2::Password.new(m_cost: some_m_cost)
instance.create(input_password)

# And remove the abstraction step:
Argon2::Password.create(input_password, m_cost: some_m_cost)
```

**Argon2::Password.create no longer accept custom salts.**

You should not be providing your own salt to the Argon2 algorithm (it does it
for you). Previously you could pass an option of `salt_do_not_supply`, which has
been removed in `sorcery-argon2 - v1.0.0`.

### The errors have been restructured

**The root level error has been renamed.**

Argon2::ArgonHashFail has been renamed to Argon2::Error

To upgrade:

```ruby
# Find any instances of Argon2::ArgonHashFail, for example...
def login(username, password)
  [...]
rescue Argon2::ArgonHashFail
  [...]
end

# And do a straight 1:1 replacement
def login(username, password)
  [...]
rescue Argon2::Error
  [...]
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
[Sorcery/argon2](https://github.com/Sorcery/argon2).

## Contact

Feel free to ask questions using these contact details:

**Current Maintainers:**

* Josh Buker ([@athix](https://github.com/athix)) | [Email](mailto:crypto+sorcery@joshbuker.com?subject=Sorcery)

## License

This gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
