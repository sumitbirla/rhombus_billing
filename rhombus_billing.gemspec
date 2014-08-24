$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rhombus_billing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rhombus_billing"
  s.version     = RhombusBilling::VERSION
  s.authors     = ["Sumit Birla"]
  s.email       = ["sbirla@tampahost.net"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of RhombusBilling."
  s.description = "TODO: Description of RhombusBilling."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.4"

  s.add_development_dependency "sqlite3"
end
