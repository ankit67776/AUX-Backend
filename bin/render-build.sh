#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rails db:migrate
