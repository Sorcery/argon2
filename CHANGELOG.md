# Changelog

Historical changelog for all versions.

## HEAD

## v1.0.0

This project has been forked from
[Technion's original argon2 wrapper](https://github.com/technion/ruby-argon2).

If you previously used `argon2` and would like to update to `sorcery-argon2`,
please see: [Migrating from `argon2` to `sorcery-argon2`](README.md#migrating-from-argon2-to-sorcery-argon2)

Changes between `argon2 - 2.0.3` and `sorcery-argon2 - 1.0.0`:

* Refactored Argon2::Password to include additional helpers and simplify hash
  creation.
* Renamed top level exception from: `Argon2::ArgonHashHail` to: `Argon2::Error`
* Added new exceptions that inherit from the top level exception.
