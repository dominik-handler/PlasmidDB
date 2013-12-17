require 'fileutils'
require 'shell_command'

namespace :backup do
  desc "restores app state from a backup file"
  task :restore => :environment do
    database_name = "lablife_production"
    path_to_app = "/home/lablife/current"

    files = Dir["#{Settings.backup_root}/lablife_#{Rails.env}_backup/*"]
    files = files.sort_by { |a| File.stat(a).mtime }
    current = files.last

    backup_file = Dir["#{current}/*.tar"].first

    Dir.mktmpdir { |tmp|
      FileUtils.cp(backup_file, tmp)
      file_name = File.basename(backup_file, '.*')
      cmd = ShellCommand.run("tar -xf #{backup_file} -C #{tmp}")

      path_to_backup = File.join(tmp, file_name)
      ## copy public files into apps public folder
      archive = Dir["#{path_to_backup}/archives/*.gz"].first
      cmd = ShellCommand.run("tar -xzf #{archive} -C #{path_to_backup}/archives/")

      path_to_public = File.join(path_to_backup, "archives", "public")
      path_to_system = File.join(path_to_backup, "archives", "public", "system")

      ## remove contents of current systems folder
      FileUtils.rm_rf(Dir.glob("#{path_to_app}/public/system/*"))

      ## copy contents of backup file into system folder
      FileUtils.cp_r(Dir.glob("#{path_to_system}/*"), "#{path_to_app}/public/system/")

      ## load database
      path_to_database = File.join(path_to_backup, "databases")
      database = Dir["#{path_to_database}/*.gz"].first

      ## first lets drop the current DB
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke

      ## load old database from stored dump
      cmd = ShellCommand.run("gunzip -c #{database} > #{path_to_database}/dump.sql")
      cmd = ShellCommand.run("psql #{database_name} < #{path_to_database}/dump.sql")
    }

    ## flush entire redis DB
    db = Redis.new(:host => "localhost", :port => 6380)
    db.flushall
  end
end
