require File.expand_path('../lib/css2less/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "css2less"
  gem.version       = Css2Less::VERSION
  gem.summary       = "CSS to LESS converter"
  gem.description   = "A ruby library which convert old CSS stylesheet into LESS dynamic stylesheet."
  gem.license       = "GPL-3"
  gem.authors       = ["Thomas Pierson", "Marcin Kulik"]
  gem.email         = ["contact@thomaspierson.fr", "m@ku1ik.com"]
  gem.homepage      = "https://github.com/thomaspierson/libcss2less"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rdoc', '~> 3.0'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end

