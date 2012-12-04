set :scm, :git
set :scm_username, 'alippert' 
set :repository, 'https://github.com/alippert/radar.git'

# rvm configuration
set :rvm_type, :system    # :user is the default
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"") # Read from local system

require "rvm/capistrano"  # Load RVM's capistrano plugin.

# We use sudo (root) for system-wide RVM installation
set :rvm_install_with_sudo, true

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

# Apply default RVM version for the current account
after "deploy:setup", "deploy:set_rvm_version"

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

  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end

  task :set_rvm_version, :roles => :app, :except => { :no_release => true } do
    run "source /etc/profile.d/rvm.sh && rvm use #{rvm_ruby_string} --default"
  end

  task :fix_setup_permissions, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} chgrp #{user_rails} #{shared_path}/log"
    run "#{sudo} chgrp #{user_rails} #{shared_path}/pids"
  end

  task :fix_permissions, :roles => :app, :except => { :no_release => true } do
    # To prevent access errors while moving/deleting
    run "#{sudo} chmod 775 #{current_path}/log"
    run "#{sudo} find #{current_path}/log/ -type f -exec chmod 664 {} \\;"
    run "#{sudo} find #{current_path}/log/ -exec chown #{user}:#{user_rails} {} \\;"
    run "#{sudo} find #{current_path}/tmp/ -type f -exec chmod 664 {} \\;"
    run "#{sudo} find #{current_path}/tmp/ -type d -exec chmod 775 {} \\;"
    run "#{sudo} find #{current_path}/tmp/ -exec chown #{user}:#{user_rails} {} \\;"
  end

end

# Helper function
def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end
