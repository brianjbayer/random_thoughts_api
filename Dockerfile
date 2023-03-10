# WIP: This is for a Development Environment ONLY!!!
# This is the Dockerfile for the random_thoughts_api
# ASSUMPTION: source is volume mounted
# docker build --no-cache -t brianjbayer/random_thoughts_api-dev .
# docker run -it --rm -v $(pwd):/app -p 3000:3000 brianjbayer/random_thoughts_api-dev
# bundle exec bin/rails server -p 3000 -b 0.0.0.0

# --- Base Image ---
# Base Image from...
# https://github.com/brianjbayer/machine-images/tree/main/rails/debian/debian-11-ruby-3.2-rails-7.0.4/dev
ARG BASE_TAG=59fa86a4010b78715afccbe51c28e402d8fd8d1c
ARG BASE_IMAGE_NAME=brianjbayer/debian-11-ruby-3.2-rails-7.0.4-dev
ARG BASE_IMAGE=${BASE_IMAGE_NAME}:${BASE_TAG}
FROM ${BASE_IMAGE}

# Static config
ARG APP_ROOT=/app

# Copy Gemfiles at minimum to bundle install
# Note that Bundler (version) is in the Base Image
WORKDIR ${APP_ROOT}
COPY Gemfile Gemfile.lock ./

ARG BUNDLER_PATH=/usr/local/bundle

WORKDIR ${APP_ROOT}
RUN bundle install \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf ${BUNDLER_PATH}/cache/*.gem \
    && find ${BUNDLER_PATH}/gems/ -name "*.c" -delete \
    && find ${BUNDLER_PATH}/gems/ -name "*.o" -delete

# Start devenv in (command line) shell
CMD bash
