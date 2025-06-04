set -o errexit

bundle install
# bin/rails assets:precompile
# bin/rails assets:clean

# bundle exec rails solid_queue:install:migrations
# bundle exec rails db:migrate

bin/rails db:migrate