set :scm, :git
set :scm_username, 'alippert' 
set :repository, 'https://github.com/alippert/radar.git'

# rvm configuration
set :rvm_ruby_string, '1.9.3-p327@radar'
require 'rvm/capistrano'
set :rvm_type, :system

set :application, 'radar'
set :deploy_to, "/opt/#{application}"

set :user, 'deploy'
ssh_options[:username] = deploy 

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"
server "apps.uschhs.org", :app, :web, :db, :primary => true

# automatically bundle new gems
require "bundler/capistrano" 

# automatically run any migrations
after 'deploy:update_code', 'deploy:migrate'

# clean up old releases on each deploy:
set :keep_releases, 5
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

