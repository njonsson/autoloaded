module Autoloaded

  def self.extended(other_module)
    caller_file_path = caller_locations.first.absolute_path
    dir_path = "#{::File.dirname caller_file_path}/#{::File.basename caller_file_path, '.rb'}"
    other_module.module_eval <<-end_module_eval, __FILE__, __LINE__
      def self.autoload?(symbol)
        #{dir_path.inspect}
      end

      def self.const_missing(symbol)
        require 'autoloaded/constant'
        ::Autoloaded::Constant.new(symbol).each_matching_filename_in #{dir_path.inspect} do |filename|
          without_ext = "\#{::File.dirname filename}/\#{::File.basename filename}"
          require without_ext
          if const_defined?(symbol)
            begin
              return const_get(symbol)
            rescue ::NameError
            end
          end
        end

        super symbol
      end
    end_module_eval
  end

end

Dir.glob "#{File.dirname __FILE__}/#{File.basename __FILE__, '.rb'}/*.rb" do |f|
  require_relative "#{File.basename __FILE__, '.rb'}/#{File.basename f, '.rb'}"
end
