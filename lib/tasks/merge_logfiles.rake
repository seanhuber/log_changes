namespace :log_changes do
  desc 'aggregates logfiles created with log_changes'
  task :merge, [:logs_path] do |_, args|
    raise ArgumentError, 'No logs directory specified' unless args[:logs_path].present? && File.directory?(args[:logs_path])
    include LogChanges::Merge
    Time.zone = 'Central Time (US & Canada)' # for timestamping log files (TODO: is this needed?)
    merge_logfiles args[:logs_path]
  end
end
