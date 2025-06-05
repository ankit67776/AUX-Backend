#!/usr/bin/env bash
set -o errexit

bundle install

RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rails db:create
RAILS_ENV=production bundle exec rails db:migrate
export RAILS_ENV=production



bundle exec rails db:create
bundle exec rails db:migrate
