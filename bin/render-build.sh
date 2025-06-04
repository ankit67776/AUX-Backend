#!/usr/bin/env bash
set -o errexit

bundle install

# Install any missing migrations (including SolidQueue's)
bundle exec rails solid_queue:install:migrations

# Precompile assets (optional if you're not using Rails frontend)
# bin/rails assets:precompile
# bin/rails assets:clean

# Migrate DB after installing migrations
bundle exec rails db:migrate
