require "rvm/capistrano"
require "bundler/capistrano"
require "sidekiq/capistrano"

default_run_options[:env] = {'RAILS_ENV' => 'production'}

set :application, "lab_life"
set :scm, :git
set :repository,      "git@gitlab.com:djurczak/brelife.git"
set :branch,          "master"
set :migrate_target,  :current

role :web, "maelstrom"                          # Your HTTP server, Apache/etc
role :app, "maelstrom"                          # This may be the same as your `Web` server
role :clockwork, "maelstrom"                          # This may be the same as your `Web` server
role :sidekiq, "maelstrom"                          # This may be the same as your `Web` server
role :db,  "maelstrom", :primary => true        # This is where Rails migrations will run
role :solr, "maelstrom"                          # This may be the same as your `Web` server

set :deploy_via, :remote_cache
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

before "backups:restore", "sidekiq:stop"
before "backups:restore", "clockwork:stop"
after "backups:restore", "sidekiq:start"
after "backups:restore", "clockwork:start"

namespace :deploy do
  desc "Symlink shared/* files"
  task :symlink_shared, :roles => :app do
    #run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :start do ; end

  task :stop do ; end

  task :restart, :roles => :app, :except => { :no_release => true } do
   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

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

