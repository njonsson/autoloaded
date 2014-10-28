def without_side_effects
  return nil unless block_given?

  out_reader, out_writer = IO.pipe.collect { |io| io.tap(&:binmode) }
  err_reader, err_writer = IO.pipe.collect { |io| io.tap(&:binmode) }

  pid = fork do
    out_reader.close
    err_reader.close

    begin
      out_writer.write Marshal.dump(yield)
    rescue => e
      clean_backtrace = e.backtrace.reject do |frame|
        frame.include? __FILE__
      end
      e.set_backtrace clean_backtrace
      err_writer.write Marshal.dump(e)
      raise e
    end
  end

  Process.wait pid

  out_writer.close
  err_writer.close

  return Marshal.load(out_reader.read) if $?.success?

  raise Marshal.load(err_reader.read)
end
