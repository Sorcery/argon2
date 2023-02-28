# Argon2 - Ruby Wrapper

A ruby wrapper for the Argon2 password hashing algorithm.

*This is an independent project, and not official from the PHC team.*

This gem provides a 1:1 replacement for the `argon2` gem, with various
improvements. Want to know more about why `argon2` was forked?
[Read more](#why-fork-argon2)

Wish to upgrade an existing application to use the improved API?
[Migration guide](#migrating-from-argon2-to-sorcery-argon2)

This fork is kept up-to-date with `argon2`, latest sync: `argon2 - v2.2.0`

## Table of Contents

1. [Useful Links](#useful-links)
2. [API Summary](#api-summary)
3. [Installation](#installation)
4. [Why fork `argon2`?](#why-fork-argon2)
5. [Migrating from `argon2` to `sorcery-argon2`](#migrating-from-argon2-to-sorcery-argon2)
6. [Contributing](#contributing)
7. [Contact](#contact)
8. [License](#license)

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

## Why fork `argon2`?

While implementing Argon2 support in Sorcery v1, I noticed that the current
ruby wrapper (`argon2` - [technion/ruby-argon2](https://github.com/technion/ruby-argon2))
had some questionable design decisions, and attempted to address them through a
pull request. The sole maintainer of the gem rejected these changes summarily,
without pointing out any specific concerns other than not understanding why the
changes were necessary. This lead to me ([@joshbuker](https://github.com/joshbuker))
being directed to create a fork instead:
[technion/ruby-argon2#44](https://github.com/technion/ruby-argon2/pull/44#issuecomment-816271661)

### Why should I trust this fork?

You shouldn't trust this code more than you trust any other open source project.
It's written by someone you don't know, and even if there is no malicious
intent, there is no guarantee that the code is secure. Open source security is
driven by having the community vett popular libraries, and discovering flaws
through the sheer number of intelligent community members looking at the code.

That being said, the original library `argon2` also falls under the same
category. Ultimately, it was also written by a single person and is not
thoroughly vetted by the community at the time of writing. A community member
([@joshbuker](https://github.com/joshbuker), in this case) finding flaws in the
implementation, and the fixes being rejected from upstream, is how this fork
came into being.

### What are the changes, why are they necessary?

The Argon2::Password interface was, to put it bluntly, poorly executed in the
original library. The Password class instance was not a representation of an
Argon2 password as one would expect, but instead an unnecessary abstraction
layer used to store the settings passed to the underlying Argon2 C Library. This
not only led to an overly complicated method of generating Argon2 hashes, but
also meant that the class could not be used to read data back out of an Argon2
digest.

Originally, to generate an Argon2 hash/digest, one would have to do the
following:

```ruby
# Create an instance of the Argon2::Password class to store your options:
instance = Argon2::Password.new(t_cost: 4, m_cost: 16)
# Use this instance to generate the hash by calling create:
instance.create(password)
    => "$argon2i$v=19$m=65536,t=2,p=1$jL7lLEAjDN+pY2cG1N8D2g$iwj1ueduCvm6B9YVjBSnAHu+6mKzqGmDW745ALR38Uo"
```

Not only is this abstraction step unnecessary, it opens up a new way for
developers to make a security mistake. New salts are only generated on the
creation of a new Argon2::Password instance, meaning if you reuse the instance,
those passwords will share the same salt.

```ruby
instance = Argon2::Password.new(t_cost: 4, m_cost: 16)
# digest1 and digest2 will share the same salt:
digest1 = instance.create(password1)
digest2 = instance.create(password2)
```

Also, because of how the instance of Argon2::Password was designed, it cannot be
used for reading information back out of an Argon2::Password. This is a summary
of the original Argon2::Password API:

```ruby
# Class methods
Argon2::Password.create(password) # Uses the default options to create a digest
Argon2::Password.valid_hash?(digest)
Argon2::Password.verify_password(password, digest, pepper = nil)

# Instance Methods
argon2 = Argon2::Password.new(options = {}) # Purely for storing options
argon2.create(password) # Take the options and generate an Argon2 digest
```

Compare this with `sorcery-argon2`:

```ruby
# Class methods
Argon2::Password.create(password, options = {}) # Same as before but accepts passing options
Argon2::Password.valid_hash?(digest)
Argon2::Password.verify_password(password, digest, pepper = nil)

# Instance Methods
argon2 = Argon2::Password.new(digest) # Now represents an Argon2 digest
argon2 == other_argon2 # Which can be compared with `==` against other Argon2::Password instances
argon2.matches?(password, pepper = nil) # Or against the original password
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

Another minor issue is that all library errors fall to a single non-descriptive
class:

```ruby
Argon2::ArgonHashFail
```

Compare with `sorcery-argon2`:

```ruby
Argon2::Error # Replaces `Argon2::ArgonHashFail`

# The following errors all inherit from Argon2::Error, and allow you to catch
# specifically the error you're interested in:
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

Finally, the original library documentation is not only incomplete, but
straight up broken/inaccurate in some areas. `sorcery-argon2` has fixed these
issues, and has 100% documentation of the API.

* [`argon2` Documentation](https://rubydoc.info/gems/argon2)
* [`sorcery-argon2` Documentation](https://rubydoc.info/gems/sorcery-argon2)

## Migrating from `argon2` to `sorcery-argon2`

There are two primary changes going from `argon2` to `sorcery-argon2`:

### The Argon2::Password API has been refactored

*Argon2::Password.new and Argon2::Password.create are now different.*

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

*Argon2::Password.create no longer accepts custom salts.*

You should not be providing your own salt to the Argon2 algorithm (this library
does it for you). Previously you could pass an option of `salt_do_not_supply`,
which has been removed in `sorcery-argon2 - v1.0.0`.

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

* Josh Buker ([@joshbuker](https://github.com/joshbuker)) | [Email](mailto:crypto+sorcery@joshbuker.com?subject=Sorcery)

## License

This gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
