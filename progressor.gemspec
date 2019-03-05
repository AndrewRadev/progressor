require File.expand_path('../lib/progressor/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'progressor'
  s.version = Progressor::VERSION
  s.authors = ['Andrew Radev']
  s.email   = ['andrey.radev@gmail.com']

  s.homepage    = 'https://github.com/AndrewRadev/progressor'
  s.license     = 'MIT'
  s.summary     = 'Measure iterations in a long-running task'
  s.description = <<~EOF
    Provides a way to measure how long each loop in a task took, outputting a
    report with an estimated time till the task is done.
  EOF

  s.add_development_dependency "bundler", "~> 1.17"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "timecop", "~> 0.9"

  s.files         = Dir['{lib}/**/*.rb', 'LICENSE', '*.md']
  s.require_paths = ['lib']
end
