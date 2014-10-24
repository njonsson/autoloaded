namespace :lib do
  desc "Load each library file individually, looking for missing 'require' statements"
  task :each do
    Dir.chdir 'lib' do
      Dir.glob( '**/*.rb' ) do |f|
        next if f == 'tasks.rb'

        puts "Loading #{f} ..."
        fail unless system( "/usr/bin/env bundle exec ruby -e 'require #{f.inspect}'" )
      end
    end
  end
end
