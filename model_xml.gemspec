Gem::Specification.new do |s|
  s.name        = "model_xml"
  s.version     = '1.0.4'
  s.authors     = "Rob Anderson"
  s.email       = "rob.anderson@paymentcardsolutions.co.uk"
  s.summary     = "Ruby object to xml converter"
  s.description = "Simple replacement for ActiveRecord's default to_xml"

  s.add_dependency 'builder', '>= 2.1.2'

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
