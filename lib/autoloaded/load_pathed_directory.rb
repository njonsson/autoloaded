require 'pathname'

# Enumerates the source files in a directory, relativizing their paths using the
# Ruby load path.
#
# @since 1.3
#
# @api private
class Autoloaded::LoadPathedDirectory

  # The file extension of source files.
  SOURCE_FILE_EXTENSION = '.rb'

private

  def self.join(path1, path2)
    paths = [path1, path2].reject do |path|
      path.to_s.empty?
    end
    (paths.length < 2) ? paths.first : ::File.join(*paths)
  end

  def self.ruby_load_paths
    $:
  end

  def self.source_basename(source_filename)
    ::File.basename source_filename, SOURCE_FILE_EXTENSION
  end

public

  # The full path of a source directory.
  #
  # @return [String] a directory path
  attr_reader :path

  # Constructs a new _LoadPathedDirectory_ with the specified _path_.
  #
  # @param [String] path the value of _#path_
  #
  # @raise [ArgumentError] _path_ is +nil+ or a relative path
  def initialize(path)
    raise ::ArgumentError, "can't be nil" if path.nil?

    @path = path.dup.freeze
    if ::Pathname.new(@path).relative?
      raise ::ArgumentError, "can't be relative"
    end
  end

  # Enumerates the source files in _#path_, relativizing their paths if possible
  # using the longest applicable entry in the Ruby load path (that is,
  # <tt>$:</tt>). File names are rendered without _SOURCE_FILE_EXTENSION_.
  # Yielded paths are guaranteed usable in +require+ statements unless elements
  # of the Ruby load path are removed or changed.
  #
  # @yield [String] each source file in _#path_, formatted for use in +require+
  #                 statements
  #
  # @return [LoadPathedDirectory] the _LoadPathedDirectory_
  #
  # @see #path
  # @see https://ruby-doc.org/core/Kernel.html#method-i-require Kernel#require
  def each_source_filename
    if (ruby_load_path = closest_ruby_load_path)
      ::Dir.chdir ruby_load_path do
        glob = self.class.join(path_from(ruby_load_path),
                               "*#{SOURCE_FILE_EXTENSION}")
        ::Dir.glob glob do |file|
          yield without_source_file_extension(file)
        end
      end
    else
      glob = self.class.join(path, "*#{SOURCE_FILE_EXTENSION}")
      ::Dir.glob glob do |file|
        yield without_source_file_extension(file)
      end
    end

    self
  end

private

  def closest_ruby_load_path
    closest = self.class.ruby_load_paths.inject(score: 0) do |close, load_path|
      score = path.length - path_from(load_path).length
      (close[:score] < score) ? {score: score, load_path: load_path} : close
    end
    closest[:load_path]
  end

  def path_from(other_path)
    # Don't use Pathname#relative_path_from because we want to avoid introducing
    # double dots. The intent is to render the path as relative, if and only if
    # it is a subdirectory of 'other_path'.
    pattern = /^#{::Regexp.escape other_path.to_s.chomp(::File::SEPARATOR)}#{::Regexp.escape ::File::SEPARATOR}?/
    path.gsub pattern, ''
  end

  def without_source_file_extension(path)
    if (dirname = ::File.dirname(path)) == '.'
      dirname = nil
    end
    basename = ::File.basename(path, SOURCE_FILE_EXTENSION)
    self.class.join dirname, basename
  end

end
