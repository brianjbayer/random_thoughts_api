#---------------------------
#--- random_thoughts_api ---
#---------------------------
# TODO: Convert this back to using pre-built machine images
# Build and Run deployment image
# docker build --no-cache -t rta .
# docker run -it --rm -p 3000:3000 rta

# Build and Run development environment image
# docker build --no-cache --target devenv -t rta-dev .
# docker run -it --rm -v $(pwd):/app -p 3000:3000 rta-dev

# --- Base Image ---
ARG BASE_IMAGE=ruby:3.2.1-slim-bullseye
FROM ${BASE_IMAGE} AS ruby-base

#--- Base Builder Stage ---
FROM ruby-base AS base-builder

# TODO: Update bundler version
ARG BUNDLER_VER=2.4.8

# Install base build packages needed for both devenv and deploy builders
ARG BASE_BUILD_PACKAGES='build-essential libpq-dev'

RUN apt-get update \
  && apt-get -y dist-upgrade \
  && apt-get -y install ${BASE_BUILD_PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  # Update gem command to latest
  && gem update --system \
  # install bundler and rails versions
  && gem install bundler:$BUNDLER_VER

# NOTE: End of machine-specific

# Copy Gemfiles
WORKDIR /app
COPY Gemfile Gemfile.lock ./

#--- Dev Environment Builder Stage ---
FROM base-builder AS devenv-builder

# NOTE: Machine specific
ARG DEVENV_PACKAGES='git vim curl postgresql-client'

# NOTE: App specific
ARG BUNDLER_PATH=/usr/local/bundle

# Install dev environment specific build packages
RUN apt-get update \
  && apt-get -y dist-upgrade \
  && apt-get -y install ${DEVENV_PACKAGES} \
  && rm -rf /var/lib/apt/lists/* \
  # NOTE: End of machine-specific
  # Install app dependencies
  && bundle install \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf ${BUNDLER_PATH}/cache/*.gem \
    && find ${BUNDLER_PATH}/gems/ -name "*.c" -delete \
    && find ${BUNDLER_PATH}/gems/ -name "*.o" -delete

# --- Dev Environment Image ---
FROM devenv-builder AS devenv

WORKDIR /app

# Start devenv in (command line) shell
CMD bash

#--- Deploy Builder Stage ---
FROM base-builder AS deploy-builder

# NOTE: App specific
ARG BUNDLER_PATH=/usr/local/bundle

# NOTE: App specific
RUN bundle config set --local without 'development:test' \
    && bundle install \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf ${BUNDLER_PATH}/cache/*.gem \
    && find ${BUNDLER_PATH}/gems/ -name "*.c" -delete \
    && find ${BUNDLER_PATH}/gems/ -name "*.o" -delete \
    # Configure bundler to lock to Gemfile.lock
    && bundle config --global frozen 1

#--- Deploy Image ---
FROM ruby-base AS deploy

# Install runtime packages
ARG RUNTIME_PACKAGES='postgresql-client'
# Update package info since this is from base image not builder
RUN apt-get update \
  && apt-get -y dist-upgrade \
  && apt-get -y install ${RUNTIME_PACKAGES} \
  && rm -rf /var/lib/apt/lists/*

# Add user for running app
RUN adduser --disabled-password --gecos '' deployer
USER deployer

WORKDIR /app

# Copy the built gems directory from builder layer
COPY --from=deploy-builder --chown=deployer /usr/local/bundle/ /usr/local/bundle/

# Copy the app source
COPY --chown=deployer . /app/

# Run the server
CMD ./entrypoint.sh
