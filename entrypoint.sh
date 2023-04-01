#!/bin/sh
# ----------------------------------------------------------------------
# Docker Convention (Production Image) Startup Script
# This script is intended to startup the application server
#
# NOTE: This currently runs the Rails Migrations
# ----------------------------------------------------------------------
# Exit script on any errors
set -e

echo "[$0]: STARTING APPLICATION SERVER..."

echo 'Setting and Exporting RAILS_ENV (default is production)...'
export RAILS_ENV=${RAILS_ENV:-production}
echo "...RAILS_ENV [${RAILS_ENV}]"

echo 'Setting and Exporting RAILS_LOG_TO_STDOUT...'
export RAILS_LOG_TO_STDOUT=

echo 'Removing any leftover pid files...'
if [ -z ${PIDFILE} ]; then
  echo '...Removing any (default) tmp/pids/server.pid file'
  rm -f tmp/pids/server.pid
else
  echo "...Removing any specified PIDFILE [${PIDFILE}]"
  rm -f ${PIDFILE}
fi

# NOTE: Remove this if database is managed outside of the application
echo 'Run database migrations...'
bundle exec bin/rails db:migrate

echo "Start application server: PORT [${PORT}] HOST [${HOST}] ARGS [$@] ..."
# NOTE: Support any PORT and HOST environment variables and script arguments
bundle exec bin/rails server -p ${PORT:-3000} -b ${HOST:-0.0.0.0} "$@"
