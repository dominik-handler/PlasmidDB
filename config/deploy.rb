require 'yaml'
require "rvm/capistrano"
require "bundler/capistrano"
require "sidekiq/capistrano"

raise "Tokens file is missing, can't deploy" unless File.exists?("config/tokens.yml")
tokens = YAML.load(File.open("config/tokens.yml", &:read))

default_run_options[:env] = {
  "RAILS_ENV" => "production"
}

set :application, "lab_life"
set :scm, :git
set :repository,      "git@github.com:djurczak/brelife.git"
set :branch,          "master"
set :migrate_target,  :current

role :web, "maelstrom.imp.univie.ac.at"                          # Your HTTP server, Apache/etc
role :app, "maelstrom.imp.univie.ac.at"                          # This may be the same as your `Web` server
role :clockwork, "maelstrom.imp.univie.ac.at"                          # This may be the same as your `Web` server
role :sidekiq, "maelstrom.imp.univie.ac.at"                          # This may be the same as your `Web` server
role :db,  "maelstrom.imp.univie.ac.at", :primary => true        # This is where Rails migrations will run
role :solr, "maelstrom.imp.univie.ac.at"                          # This may be the same as your `Web` server

#set :deploy_via, :remote_cache
set :use_sudo, false
set :user, "lablife"
set :deploy_to, "/home/lablife"
set :rails_env, "production"
set :rvm_type, :system

ssh_options[:forward_agent] = true
set :keep_releases, 3

namespace :backups do
  desc "restore from newest backup"
  task :restore, :roles => :app do
    run("sudo stop nginx || true")
    run("cd '#{current_path}' && #{rake} backup:restore")
    run("sudo start nginx")
  end
end

before "backups:restore", "solr:stop"
before "backups:restore", "sidekiq:stop"
before "backups:restore", "clockwork:stop"
after "backups:restore", "sidekiq:start"
after "backups:restore", "clockwork:start"
after "backups:restore", "solr:hard_reindex"

before 'bundle:install', 'deploy:symlink_db'
before 'bundle:install', 'deploy:setenv'

namespace :deploy do
  desc "Symlink database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{release_path}/config/database.yml.org #{release_path}/config/database.yml"
  end

  desc "Set ENV variables"
  task :setenv, :roles => :app do
    env_string = tokens.map { |key,value| "#{key}=#{value}" }.join("\n")
    run "echo '#{env_string}' >> #{release_path}/.env"
  end

  task :start do ; end

  task :stop do ; end

  # Ask whether to reindex before restarting Passenger
  task :restart, :roles => :app, :except => {:no_release => true} do
    solr.reindex if 'y' == Capistrano::CLI.ui.ask("\n\n Should I reindex all models? (anything but y will cancel)")
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  desc 'create shared data and pid dirs for Solr'
  task :setup_solr_shared_dirs do
    # conf dir is not shared as different versions need different configs
    %w(data pids).each do |path|
      run "mkdir -p #{shared_path}/solr/#{path}"
    end
  end

  desc 'substituses current_path/solr/data and pids with symlinks to the shared dirs'
  task :link_to_solr_shared_dirs do
    %w(solr/data solr/pids).each do |solr_path|
      run "rm -fr #{current_path}/#{solr_path}" #removing might not be necessary with proper .gitignore setup
      run "ln -s #{shared_path}/#{solr_path} #{current_path}/#{solr_path}"
    end
  end
end

after 'deploy:setup', 'deploy:setup_solr_shared_dirs'
# rm and symlinks every time we finished uploading code and symlinking to the new release
after 'deploy:update', 'deploy:link_to_solr_shared_dirs'

application_sidekiq_index = 0

namespace :sidekiq do
  desc "stop sidekiq"
   task :stop, :roles => :sidekiq, :on_no_matching_servers => :continue do
     run "sudo stop sidekiq app=#{current_path} index=#{application_sidekiq_index} || true"
   end

  desc "sidekiq status"
  task :status, :roles => :sidekiq, :on_no_matching_servers => :continue do
     run "sudo status sidekiq app=#{current_path} index=#{application_sidekiq_index} || true"
  end

  desc "start sidekiq"
  task :start, :roles => :sidekiq, :on_no_matching_servers => :continue do
     run "sudo start sidekiq app=#{current_path} index=#{application_sidekiq_index}"
  end

  desc "restart sidekiq"
  task :restart, :roles => :sidekiq, :on_no_matching_servers => :continue do
    stop
    start
  end
end

after "deploy:stop", "sidekiq:stop"
after "deploy:start", "sidekiq:start"
after "deploy:restart", "sidekiq:restart"

namespace :clockwork do
  desc "Stop clockwork"
   task :stop, :roles => :clockwork, :on_no_matching_servers => :continue do
     run "daemon --inherit --name=clockwork_lablife --env='#{rails_env}' --output=#{log_file} --pidfile=#{pid_file} -D #{current_path} --stop || true"
   end

  desc "clockwork status"
  task :status, :roles => :clockwork, :on_no_matching_servers => :continue do
    run "daemon --inherit --name=clockwork_lablife --env='#{rails_env}' --output=#{log_file} --pidfile=#{pid_file} -D #{current_path} --verbose --running || true"
  end

  desc "Start clockwork"
  task :start, :roles => :clockwork, :on_no_matching_servers => :continue do
    run "daemon --inherit --name=clockwork_lablife --env='#{rails_env}' --output=#{log_file} --pidfile=#{pid_file} -D #{current_path} -- bundle exec clockwork config/clock.rb"
  end

  desc "Restart clockwork"
  task :restart, :roles => :clockwork, :on_no_matching_servers => :continue do
    stop
    start
  end

  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end

  def log_file
    fetch(:clockwork_log_file, "#{shared_path}/log/clockwork.log")
  end

  def pid_file
    fetch(:clockwork_pid_file, "#{current_path}/tmp/pids/clockwork.pid")
  end
end

after "deploy:stop", "clockwork:stop"
after "deploy:start", "clockwork:start"
after "deploy:restart", "clockwork:restart"

# Tasks to interact with Solr and SunSpot
namespace :solr do
  desc "start solr"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "daemon -U --inherit --name=solr_lablife --env='#{rails_env}' --output=#{log_file} --pidfile=#{pid_file} -D #{current_path} -- bundle exec sunspot-solr run -p 8983 -s #{current_path}/solr/ -d #{current_path}/solr/data/"
  end

  desc "stop solr"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "daemon -U --inherit --name=solr_lablife --env='#{rails_env}' --output=#{log_file} --pidfile=#{pid_file} -D #{current_path} --stop || true"
  end

  desc "solr status"
  task :status, :roles => :app, :except => { :no_release => true } do
    run "daemon -U --inherit --name=solr_lablife --env='#{rails_env}' --output=#{log_file} --pidfile=#{pid_file} -D #{current_path} --verbose --running || true"
  end

  desc "stop solr, remove data, start solr, reindex all records"
  task :hard_reindex, :roles => :app do
    stop
    run "rm -rf #{shared_path}/solr/data/*"
    start
    reindex
  end

  desc "simple reindex" #note the yes | reindex to avoid the nil.chomp error
  task :reindex, roles: :app do
    run "cd #{current_path} && yes | #{rails_env} bundle exec rake sunspot:solr:reindex"
  end

  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end

  def log_file
    fetch(:solr_log_file, "#{shared_path}/log/solr.log")
  end

  def pid_file
    fetch(:solr_pid_file, "#{current_path}/tmp/pids/solr.pid")
  end
end
