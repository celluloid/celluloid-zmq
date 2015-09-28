#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

Dir["tasks/**/*.rake"].each { |task| load task }

default_tasks = ["spec"]
default_tasks << "rubocop" unless ENV["CI"]

task default: default_tasks
task ci: %w(spec)
