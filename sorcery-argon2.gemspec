# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'argon2/version'

version  = Argon2::VERSION
repo_url = 'https://github.com/sorcery/argon2'

Gem::Specification.new do |s|
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.name        = 'sorcery-argon2'
  s.summary     = 'A Ruby wrapper for the Argon2 Password hashing algorithm'
  s.description =
    'Provides a minimal ruby wrapper for the Argon2 password hashing algorithm.'

  s.required_ruby_version = '>= 2.5.0'

  s.license  = 'MIT'
  s.author   = 'Josh Buker'
  s.email    = 'crypto@joshbuker.com'
  s.homepage = repo_url
  s.metadata = {
    'bug_tracker_uri' => "#{repo_url}/issues",
    'changelog_uri' => "#{repo_url}/releases/tag/v#{version}",
    'documentation_uri' => 'https://rubydoc.info/gems/sorcery-argon2',
    'source_code_uri' => "#{repo_url}/tree/v#{version}"
  }

  s.cert_chain = ['certs/athix.pem']
  if $PROGRAM_NAME =~ /gem\z/
    s.signing_key = File.expand_path('~/.ssh/gem-private_key.pem')
  end

  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.files << `find ext`.split

  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'ffi',          '~> 1.14'
  s.add_dependency 'ffi-compiler', '~> 1.0'

  # Gems required for testing the wrapper locally.
  s.add_development_dependency 'bundler',        '~> 2.0'
  s.add_development_dependency 'minitest',       '~> 5.8'
  s.add_development_dependency 'rake',           '~> 13.0.1'
  s.add_development_dependency 'rubocop',        '~> 1.7'
  s.add_development_dependency 'simplecov',      '~> 0.20'
  s.add_development_dependency 'simplecov-lcov', '~> 0.8'

  # Argon2 C Extension
  s.extensions << 'ext/argon2_wrap/extconf.rb'
end
