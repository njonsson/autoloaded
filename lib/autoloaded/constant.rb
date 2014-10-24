require 'autoloaded/refine/string/to_source_filename'
require 'set'

using ::Autoloaded::Refine::String::ToSourceFilename

module Autoloaded; end

class Autoloaded::Constant

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def each_matching_filename_in(directory)
    filenames = ::Set.new

    ::Dir.chdir directory do
      filename = [name.to_s.to_source_filename, extension].join
      if ::File.file?(filename) && filenames.add?(filename)
        yield ::File.join(directory, filename)
      end

      name_signature = signature(name)
      ::Dir.glob(['*', extension].join, ::File::FNM_CASEFOLD) do |f|
        f_signature = signature(::File.basename(f, extension))
        if (f_signature == name_signature) && filenames.add?(f)
          yield ::File.join(directory, f)
        end
      end
    end
  end

private

  def extension
    '.rb'
  end

  def signature(string)
    string.to_s.gsub(/[^a-z0-9]/i, '').downcase
  end

end
