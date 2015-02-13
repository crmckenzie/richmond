require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  pattern = Dir['spec/**/*_spec.rb']
  t.pattern = pattern 
end
