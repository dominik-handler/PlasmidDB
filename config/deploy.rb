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
    run("sudo stop nginx")
    run("cd '#{current_path}' && #{rake} backup:restore")
    run("sudo start nginx")
  end
end

before "backups:restore", "sidekiq:stop"
#before "backups:restore", "clockwork:stop"
after "backups:restore", "sidekiq:start"
#after "backups:restore", "clockwork:start"

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

application_sidekiq_index = 1

namespace :sidekiq do
  desc "stop sidekiq"
   task :stop, :roles => :sidekiq, :on_no_matching_servers => :continue do
     run "sudo stop sidekiq app=#{current_path} index=#{application_sidekiq_index}"
   end

  desc "sidekiq status"
  task :status, :roles => :sidekiq, :on_no_matching_servers => :continue do
     run "sudo status sidekiq app=#{current_path} index=#{application_sidekiq_index}"
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