$:.push File.expand_path("../lib", __FILE__)

require 'git-prepare-branch/version'

Gem::Specification.new do |s|
  s.name        = 'git-prepare-branch'
  s.version     = GitPrepareBranch::Version
  s.licenses    = ['MIT']
  s.summary     = 'Command to assist in preparing git branches for review'
  s.description = 'Command to assist in preparing git branches for review'
  s.authors     = ['Adam Phillips']
  s.email       = 'adam@29ways.co.uk'
  s.homepage    = 'https://github.com/adamphillips/git-prepare-branch'

  s.require_paths = ["lib"]
  s.bindir      = 'bin'
  s.executables << 'git-prepare-branch'
  s.files       = Dir['README.md', 'lib/**/*']

  s.add_runtime_dependency 'rainbow', '~> 3.0'

  s.add_development_dependency 'pry-byebug', '~> 3.6'
  s.add_development_dependency 'minitest-reporters', '~> 1.2'
end