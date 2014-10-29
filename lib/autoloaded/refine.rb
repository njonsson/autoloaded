module Autoloaded

  # @private
  module Refine; end

end

Dir.glob "#{File.dirname __FILE__}/#{File.basename __FILE__, '.rb'}/*.rb" do |f|
  require_relative "#{File.basename __FILE__, '.rb'}/#{File.basename f, '.rb'}"
end
