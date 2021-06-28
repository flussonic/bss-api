# frozen_string_literal: true

require_relative 'lib/bss_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'bss-api'
  spec.version       = BssApi::VERSION
  spec.authors       = ['Kirill Usanov']
  spec.email         = ['kirill.usanov.dev@gmail.com']

  spec.summary       = 'Unified API'
  spec.description   = 'Unified API'
  spec.homepage      = 'https://github.com/flussonic/bss-api'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/flussonic/bss-api'
  spec.metadata['changelog_uri'] = 'https://github.com/flussonic/bss-api#readme'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Register a new dependency of your gem
  spec.add_dependency 'rails', '>= 5.0.7.2'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
