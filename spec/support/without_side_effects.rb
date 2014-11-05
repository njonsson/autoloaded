def without_side_effects
  return nil unless block_given?

  out_reader, out_writer = IO.pipe.collect { |io| io.tap(&:binmode) }
  err_reader, err_writer = IO.pipe.collect { |io| io.tap(&:binmode) }

  pid = fork do
    out_reader.close
    err_reader.close

    begin
      out_writer.write Marshal.dump(yield)
    rescue Exception => e
      clean_backtrace = e.backtrace.reject do |frame|
        frame.include? __FILE__
      end
      e.set_backtrace clean_backtrace
      err_writer.write Marshal.dump(e)
      raise e
    end

    # The codeclimate-test-reporter RubyGem uses Kernel#at_exit to hook the end
    # of test/spec runs for sending coverage statistics to their web service. We
    # need to skip that hook in this process fork because this is not the end of
    # a test/spec run, only of a process fork.
    exit!(true) if ENV['CODECLIMATE_REPO_TOKEN']
  end

  Process.wait pid

  out_writer.close
  err_writer.close

  return Marshal.load(out_reader.read) if $?.success?

  raise Marshal.load(err_reader.read)
end
