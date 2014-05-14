require 'rollbar'
require 'shell_command'

class PerformBackupWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :critical, :retry => :false, :backtrace => true

  def perform
    app_root = Rails.root.to_s
    backup_root = Settings.backup_root

    cmdline =
      "APP_PATH=#{app_root} BACKUP_ROOT=#{backup_root} " \
      "bundle exec backup perform --trigger lablife_#{Rails.env}_backup " \
      "--config_file 'config/backup/models/plasmiddb_backup.#{Rails.env}.rb'"

    ShellCommand.run(cmdline) do |cmd|
      raise "Backup failed: #{cmd.stdout}\n #{cmd.stderr}\n" unless cmd.success?
      Rollbar.report_message("Backup successful", "info")
    end

    true
  end
end
