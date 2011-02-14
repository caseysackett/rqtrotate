
# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "rqtrotate/version"

Gem::Specification.new do |s|
  s.name        = "rqtrotate"
  s.version     = Rqtrotate::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Umbel"]
  s.email       = ["chrisu@dvdempire.com"]
  s.homepage    = "https://github.com/TheSkunkworx/rqtrotate"
  s.summary     = %q{Pure ruby library toe detect and affect rotation of QuickTime movies}
  s.description = %q{Pure ruby library toe detect and affect rotation of QuickTime movies}

  s.rubyforge_project = "rqtrotate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
