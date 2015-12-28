Gem::Specification.new do |s|
  s.name        = 'pulse_logger'
  s.version     = '1.0.0'
  s.date        = '2015-12-14'
  s.summary     = 'pulse-logger'
  s.description = 'A syslog-logger for Pulse applications'
  s.authors     = ['Pwnie Express']
  s.email       = 'brendan@pwnieexpress.com'
  s.files       = ['lib/pulse_logger.rb']
  s.add_development_dependency 'rspec', ['>= 0']
end