require 'shell_command'

class PerformBackupWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :critical, :retry => :false, :backtrace => true

  def perform
    cmdline = "bundle exec backup perform --trigger plasmiddb_#{Rails.env}_backup --config_file 'config/backup/models/plasmiddb_backup.#{Rails.env}.rb'"

    ShellCommand.run(cmdline) do |cmd|
      raise "Backup failed: #{cmd.stdout}\n #{cmd.stderr}\n" unless cmd.success?
      puts cmd.success?
    end
    true
  end
end
