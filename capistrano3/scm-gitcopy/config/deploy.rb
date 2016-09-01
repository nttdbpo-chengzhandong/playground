# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'my_cakephp3_app'
set :repo_url, 'git@github.com:k1LoW/my_cakephp3_app.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, '/var/www/deploy/to'
set :scm, :gitcopy

set :pty, true

append :linked_dirs, 'tmp/cache/models', 'tmp/cache/persistent', 'tmp/cache/views', 'logs'

set :keep_releases, 5

namespace :deploy do
  desc 'Setup CakePHP app'
  task :setapp do
    on roles(:all) do
      within release_path do
        # @notice https://github.com/capistrano/capistrano/issues/719
        execute :sudo, :chmod, '-R', '777', 'tmp/'
        execute :rm, '-rf', 'tmp/cache/models/*'
        execute :rm, '-rf', 'tmp/cache/persistent/*'
        execute :rm, '-rf', 'tmp/cache/views/*'
        execute :curl, '-s', 'http://getcomposer.org/installer', '|', 'php'
        execute :php, 'composer.phar', 'install', '--no-dev'
      end
      upload!("#{File.dirname(__FILE__)}/#{fetch(:stage)}/app_local.php", "#{release_path}/config/app_local.php")
    end
  end

  desc 'Migrate database'
  task :migrate do
    on roles(:all) do
      within release_path do
        # @see http://k1low.hatenablog.com/entry/2016/06/09/083000
        execute :ridgepole, '-c', 'config/database.yml', '--apply', '-f', 'config/Schemafile', '--enable-migration-comments'
      end
    end
  end
end

after 'deploy:symlink:linked_dirs', 'deploy:setapp'
after 'deploy:setapp', 'deploy:migrate'
