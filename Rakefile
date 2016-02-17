require "bundler/gem_tasks"
require 'yaml'
require 'sqlite3'

desc "Test task"
task :test do
    ruby "test/suite.rb"
end

desc "Create database task"
task 'db:create', :config_file do |t, args|
    args.with_defaults(:config_file => 'config.yml')
    config = YAML::load_file(args[:config_file])
    db = SQLite3::Database.new(config['database']['name'])
    File.open('schema/schema.sql') do |f|
        db.execute(f.read())
    end
end

task :default do
    sh('rake', '--tasks')
end
