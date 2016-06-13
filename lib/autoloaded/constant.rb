require 'autoloaded/refine/string/to_source_filename'
require 'set'

using ::Autoloaded::Refine::String::ToSourceFilename

module Autoloaded; end

# Represents a Ruby constant.
#
# @since 0.0.1
#
# @api private
class Autoloaded::Constant

  attr_reader :name

  def initialize(name)
    @name = name.freeze
  end

  def each_matching_filename_in(directory, &block)
    filenames = ::Set.new

    yield_qualified_name_source_filename_in(directory,
                                            unless_in: filenames,
                                            &block)
    yield_all_qualified_filenames_in(directory, unless_in: filenames, &block)
  end

private

  def extension
    '.rb'
  end

  def filename_without_extension(filename)
    "#{::File.dirname filename}/#{::File.basename filename, extension}"
  end

  def filename_without_load_path_prefix(filename)
    first_applicable_load_path = $:.detect do |path|
      filename.start_with? path
    end
    if first_applicable_load_path
      regexp = /^#{::Regexp.escape first_applicable_load_path}\/?/
      filename = filename.gsub(regexp, '')
    end
    filename
  end

  def format_filename(filename)
    filename_without_load_path_prefix filename_without_extension(filename)
  end

  def name_signature
    @name_signature ||= signature(name)
  end

  def name_source_filename
    @name_source_filename ||= [name.to_s.to_source_filename, extension].join
  end

  def qualified_glob_in(directory)
    ::File.join(directory, ['*', extension].join)
  end

  def signature(string)
    string.to_s.gsub(/[^a-z0-9]/i, '').downcase
  end

  def yield_all_qualified_filenames_in(directory, unless_in: nil, &block)
    unless unless_in
      raise ::ArgumentError, "missing keyword: unless_in"
    end
    ::Dir.glob(qualified_glob_in(directory), ::File::FNM_CASEFOLD) do |filename|
      filename_signature = signature(::File.basename(filename, extension))
      if (filename_signature == name_signature) &&
         unless_in.add?(::File.basename(filename))
        block.call format_filename(filename)
      end
    end
  end

  def yield_qualified_name_source_filename_in(directory, unless_in: nil, &block)
    unless unless_in
      raise ::ArgumentError, "missing keyword: unless_in"
    end
    qualified = ::File.join(directory, name_source_filename)
    if ::File.file?(qualified) && unless_in.add?(name_source_filename)
      block.call format_filename(qualified)
    end
  end

end
