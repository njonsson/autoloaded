interactor :off

debugger_gem = %w(pry-byebug pry-debugger).detect do |gem|
  `bundle show #{gem} 2>&1 >/dev/null`
  $?.success?
end
debugger_require = debugger_gem ? " --require #{debugger_gem}" : nil
guard :rspec, all_after_pass: true,
              all_on_start:   true,
              cmd: "bundle exec rspec#{debugger_require} --format progress" do
  # Run the corresponding spec (or all specs) when code changes.
  watch( %r{^lib/(.+)\.rb$} ) do |match|
    Dir["spec/#{match[1]}_spec.rb"].first || 'spec'
  end

  # Run a spec when it changes.
  watch %r{^spec/.+_spec\.rb$}

  # Run all specs when a shared spec changes.
  watch( %r{^spec/.+_sharedspec\.rb$} ) { 'spec' }

  # Run all specs when a matcher changes.
  watch( 'spec/matchers.rb' ) { 'spec' }

  # Run all specs when a support file changes.
  watch( %r{^spec/support} ) { 'spec' }

  # Run all specs when a fixture changes.
  watch( %r{^spec/fixtures} ) { 'spec' }

  # Run all specs when the RSpec configuration changes.
  watch( '.rspec'              ) { 'spec' }
  watch( 'spec/spec_helper.rb' ) { 'spec' }

  # Run all specs when the bundle changes.
  watch( 'Gemfile.lock'      ) { 'spec' }
  watch( %r{^(.+)\.gemspec$} ) { 'spec' }
end
