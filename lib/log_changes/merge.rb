module LogChanges
  module Merge
    def merge_logfiles( log_dir )
      [true, false].each do |record_changes|
        logfiles = associate_logfiles( log_dir, record_changes )

        aggregate_log_dir = File.expand_path( File.join(log_dir, "../#{Time.now.in_time_zone.strftime('%Y-%m-%d_%H%M')}_aggregated_logs#{record_changes ? '/record_changes' : ''}") )
        FileUtils.mkdir_p( aggregate_log_dir )

        logfiles.each do |log_type, logfile_paths|
          entries = []
          logfile_paths.each do |lf|
            lf_entries = logfile_entries(lf)
            if lf_entries.nil?
              puts "\nSKIPPING logfile (unable to parse entries): #{lf}\n\n"
            else
              entries += lf_entries
            end
          end
          next if entries.empty?
          entries.sort!{|e1, e2| e1[:time] <=> e2[:time]}
          merged_log = File.join(aggregate_log_dir, "#{log_type}_#{entries.first[:time].in_time_zone.strftime('%Y-%m-%d_%H%M')}_-_#{entries.last[:time].in_time_zone.strftime('%Y-%m-%d_%H%M')}.log")
          File.open( merged_log, 'w' ) do |file|
            entries.each do |entry|
              file.write "#{entry[:time].strftime('%-m/%-d/%Y at %-l:%M %p (%Z)')}\n"
              file.write "#{entry[:text]}\n\n"
            end
          end
          puts "Merged log: #{merged_log}\n  #{entries.length} #{'entry'.pluralize(entries.length)}"
        end
      end
    end

    # Returns a hash whose keys are the common log names and whose values are arrays of file paths, e.g.:
    # {
    #                     "ajax_errors" => [
    #       [ 0] "/Users/seanhuber/Downloads/record_changes/2015.08_ajax_errors.log",
    #       [ 1] "/Users/seanhuber/Downloads/record_changes/2015.09_ajax_errors.log",
    #       [ 2] "/Users/seanhuber/Downloads/record_changes/2015.10_ajax_errors.log"
    #   ],
    #               "care_plan_updates" => [
    #       [ 0] "/Users/seanhuber/Downloads/record_changes/2015.08_care_plan_updates.log",
    #       [ 1] "/Users/seanhuber/Downloads/record_changes/2015.09_care_plan_updates.log",
    #       [ 2] "/Users/seanhuber/Downloads/record_changes/2015.10_care_plan_updates.log"
    #   ],
    #                    "eval_updates" => [
    #       [ 0] "/Users/seanhuber/Downloads/record_changes/2015.08_eval_updates.log",
    #       [ 1] "/Users/seanhuber/Downloads/record_changes/2015.09_eval_updates.log",
    #       [ 2] "/Users/seanhuber/Downloads/record_changes/2015.10_eval_updates.log"
    #   ],
    # }
    def associate_logfiles( log_dir, record_changes = false )
      raise "Directory does not exist: #{log_dir}" unless File.directory?( log_dir )

      # scans for logfiles prefixed with a month stamp like "2016.03_"
      ret_h = {}
      search_path = record_changes ? File.join(log_dir, '**', 'record_changes', '*.log') : File.join(log_dir, '**', '20*_*.log')
      Dir.glob(search_path) do |log_fp|
        next if !record_changes && (log_fp.include?('record_changes') || log_fp.include?('import')) # TODO: include import
        month_stamp = File.basename(log_fp).split('_').first
        next unless month_stamp.length == 7 && month_stamp[4] == '.'
        begin
          DateTime.strptime(month_stamp, '%Y.%m')
        rescue ArgumentError
          next
        end
        log_class = File.basename(log_fp, File.extname(log_fp)).split('_')[1..-1].join('_')
        ret_h[log_class] ||= []
        ret_h[log_class] << log_fp
      end
      ret_h
    end

    # Returns an array of hashes containing time and text of each log entry, e.g.,
    # [
    #   [0] {
    #       :time => Thu, 17 Sep 2015 12:20:00 -0500,
    #       :text => "Logged by user: (bm25671) John Doe\nSome message was logged"
    #   },
    #   [1] {
    #       :time => Thu, 17 Sep 2015 12:27:00 -0500,
    #       :text => "Logged by user: (bm25671) Jane Smith\nLorem ipsum..."
    #   },
    #   [2] {
    #       :time => Thu, 17 Sep 2015 13:24:00 -0500,
    #       :text => "Logged by user: (vr16208) Charlie Williams\nblah blah blah"
    #   }
    # ]
    #
    # Returns nil if entries couldn't be parsed (unable to find lines structured DateTime)
    def logfile_entries( logfile )
      lines = File.open( logfile ).map{|l| l}
      entry_indexes = [] # lines that are just a timestamp
      lines.each_with_index do |line, idx|
        next unless first_char_is_num?( line )
        dt = begin
          DateTime.strptime(line.strip, "%m/%d/%Y at %l:%M %p (%Z)")
        rescue ArgumentError
          nil
        end
        next if dt.nil?
        next if idx > 0 && lines[idx-1].strip.present? && !lines[idx-1].strip.starts_with?('Logged by user:')
        entry_indexes << idx
      end
      return nil if entry_indexes.empty?

      # TODO: refactor (shouldn't need to loop over the logfile twice)
      entries = []
      entry_indexes.each_with_index do |entry_idx, entry_indexes_idx|
        end_idx = entry_indexes_idx == (entry_indexes.length - 1) ? (lines.length-1) : (entry_indexes[entry_indexes_idx+1]-1)
        end_idx -= 1 if lines[end_idx].starts_with?('Logged by user:')
        entry_text = lines[entry_idx+1..end_idx].join
        entry_text = lines[entry_idx-1] + entry_text if entry_idx > 0 && lines[entry_idx-1].starts_with?('Logged by user:')
        entries << {:time => DateTime.strptime(lines[entry_idx].strip, "%m/%d/%Y at %l:%M %p (%Z)"), :text => entry_text.strip}
      end
      entries
    end

    def first_char_is_num?( str )
      !(str[0] =~ /^\d/).nil?
    end
  end
end
