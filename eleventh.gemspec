$:.push File.expand_path('../lib', __FILE__)

require 'eleventh'

Gem::Specification.new do |s|
  s.name        = 'eleventh'
  s.version     = Eleventh::VERSION
  s.date        = '2015-08-13'
  s.summary     = "Synchronize locally developed Lambda functions to AWS Lambda."
  s.description = "This gem will synchronize locally developed Lambda functions to Amazon Web Services Lambda."
  s.authors     = ["Michael Wood"]
  s.email       = 'support@attendease.com'
  s.files       = ["lib/eleventh.rb"]
  s.homepage    = 'https://attendease.com'
  s.licenses    = ['MIT']
  s.executables << 'eleventh'
  s.add_dependency 'commander', '~> 4.3'
  s.add_dependency 'json', '~> 1.8'
  s.add_dependency 'rubyzip', '~> 1.1'
  s.add_dependency 'aws-sdk', '~> 2.1'
end
