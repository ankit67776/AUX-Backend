#!/usr/bin/env bash
set -o errexit

bundle install

# Install SolidQueue initializer + migrations
bundle exec rails solid_queue:install

# Run database migrations, including the solid_queue_jobs table
bundle exec rails db:migrate
