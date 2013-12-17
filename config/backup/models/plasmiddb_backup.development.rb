# encoding: utf-8

##
# Backup Generated: oligodb_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t oligodb_backup [-c <path_to_configuration_file>]
#
Backup::Model.new(:lablife_development_backup, 'PlasmidDB backup') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250
  ##
  # Archive [Archive]
  #
  # Adding a file or directory (including sub-directories):
  #   archive.add "/path/to/a/file.rb"
  #   archive.add "/path/to/a/directory/"
  #
  # Excluding a file or directory (including sub-directories):
  #   archive.exclude "/path/to/an/excluded_file.rb"
  #   archive.exclude "/path/to/an/excluded_directory
  #
  # By default, relative paths will be relative to the directory
  # where `backup perform` is executed, and they will be expanded
  # to the root of the filesystem when added to the archive.
  #
  # If a `root` path is set, relative paths will be relative to the
  # given `root` path and will not be expanded when added to the archive.
  #
  #   archive.root '/path/to/archive/root'
  #
  # For more details, please see:
  # https://github.com/meskyanichi/backup/wiki/Archives
  #
  archive :my_archive do |archive|
    # Run the `tar` command using `sudo`
    # archive.use_sudo
    archive.root "/home/jurczak/lablife/LabLife"
    archive.add "config/"
    archive.add "public/"
  end

  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    db.name               = "lablife_dev"
    db.username           = "postgres"
    db.password           = "postgres"
    db.host               = "localhost"
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = "/groups/brennecke/apps/backups/lablife"
    local.keep       = 5
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip
end
