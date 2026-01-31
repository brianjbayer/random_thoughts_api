# Docker Compose System Architecture

## Overview

This project uses a sophisticated multi-stage Docker build system with composable docker-compose configurations. The architecture supports multiple environments (development, test, CI, production) using a single Dockerfile and environment-specific docker-compose override files.

**Key Principle**: The `dockercomposerun` script orchestrates `docker compose` file composition to build the exact configuration needed for each scenario.

---

## Multi-Stage Dockerfile Architecture

### Image Hierarchy

```
ruby:4.0.1-slim-trixie (base image)
    ↓
ruby-base (FROM ruby:4.0.1-slim-trixie)
    ├→ base-builder (FROM ruby-base)
    │   └→ devenv-builder (FROM base-builder) → devenv (final development image)
    │
    └→ base-builder (FROM ruby-base)
        └→ deploy-builder (FROM base-builder) → deploy (final production image)
```

### Stage Details

**ruby-base**: Minimal Ruby 4.0.1 starting point
- Sets `BUNDLER_VERSION=4.0.5` (must match Gemfile.lock)
- All downstream stages inherit this

**base-builder**: Shared foundation for both devenv and deploy
- Installs build essentials: `build-essential libpq-dev libyaml-dev`
- Updates gem system and installs bundler
- Copies `Gemfile` and `Gemfile.lock` to `/app`
- **Critical**: Both devenv and deploy builders inherit from this, ensuring consistent base setup

**devenv-builder**: Development environment specific
- Installs dev tools: `git vim curl postgresql-client`
- Sets `BUNDLE_JOBS=4` for parallel gem installation (Rails 8 optimization)
- **Includes development and test gems** (`bundle install` without `--without`)
- Installs platform support: `ruby`, `x86_64-linux`, `aarch64-linux`
- Cleans cache to reduce layer size

**devenv**: Final development image
- Inherits from `devenv-builder`
- Working directory: `/app`
- Default command: `bash` (interactive shell)
- **Usage**: `docker build --no-cache --target devenv -t rta-dev .`

**deploy-builder**: Production environment specific
- Sets `BUNDLE_WITHOUT='development:test'` to exclude dev/test gems
- Installs only production dependencies
- Sets `bundle config --global frozen 1` to prevent accidental changes
- Cleans cache

**deploy**: Final production image
- Inherits from `ruby-base` (not deploy-builder, to minimize size)
- Creates non-root `deployer` user (locked account)
- Installs runtime packages: `postgresql-client`
- Copies built gems from deploy-builder
- Copies app source (from native filesystem)
- Default command: `./entrypoint.sh` (server startup)
- **Usage**: `docker build --no-cache -t rta .`

---

## Docker Compose File Composition System

### Core File: `docker-compose.yml`

Base service definition (app service):
- Uses image: `brianjbayer/random_thoughts_api:${APP_TAG:-latest}`
- Defines all environment variables (but doesn't set values)
- Defines ports: host `13000` → container `3000`
- Healthcheck: `bash -c 'ruby app_is ready'`
- **Never modified**: serves as the single source of truth for service structure

### Override Files (Composed via `dockercomposerun` script)

**docker-compose.db.yml** (database configuration)
- Adds `db` service: PostgreSQL image
- Sets database environment variables:
  - `POSTGRES_HOST=db` (Docker service name)
  - `POSTGRES_DB=random_thoughts_api_${RAILS_ENV}`
  - `POSTGRES_USER=random_thoughts_api_${RAILS_ENV}`
  - Database name and user change per environment (dev, test, etc.)
- App service depends on db service (healthcheck condition)
- PostgreSQL healthcheck: `pg_isready`
- **Composition flag**: `-f docker-compose.db.yml` (NOT included with `-o` flag)

**docker-compose.dev.yml** (development overrides)
- Sets image: `${APP_IMAGE:-brianjbayer/random_thoughts_api-dev:latest}`
  - Allows override via `APP_IMAGE=rta-dev` environment variable
  - Falls back to public image if not specified
- Volume mount: `${APP_SRC:-.}:/app` (local source → container `/app`)
  - Default: current directory (`.`)
  - Can override: `APP_SRC=/path/to/source`
- Default RAILS_ENV: `development`
- Provides default secrets for development (not security-critical)
- **Composition flag**: `-f docker-compose.dev.yml` (only with `-d` flag)

**docker-compose.ci.yml** (CI environment)
- Overrides image: `${APP_IMAGE}` (required; no fallback)
- **Minimal file**: only the image override
- **Composition flag**: `-f docker-compose.ci.yml` (only with `-c` flag)
- **Requirement**: Must provide `APP_IMAGE` environment variable

**docker-compose.perf.yml** (performance testing)
- Adds `perftests` service: grafana/k6 load testing tool
- Mounts k6 scripts: `${PERF_SRC:-./k6}:/k6`
- Depends on app service (healthcheck condition)
- Sets `APP_BASE_URL=http://app:3000` for tests to target
- **Composition flag**: `-f docker-compose.perf.yml` (only with `-p` flag)

---

## dockercomposerun Script: Orchestration Logic

### Script Purpose

Manages docker-compose file composition, ensuring correct environment is built.

### Options (Flags)

Flags are **orthogonal** (independent):

```bash
# Base service definition (always included)
docker-compose.yml

# Database service (EXCLUDED with -o, INCLUDED by default)
-o    App only (EXCLUDES docker-compose.db.yml)

# Environment-specific overrides (mutually exclusive)
-d    Development environment (adds docker-compose.dev.yml)
-c    CI environment (adds docker-compose.ci.yml)

# Additional services
-p    Performance tests (adds docker-compose.perf.yml)
```

**Composition Examples**:

```bash
# Default (base + db)
./script/dockercomposerun [CMD]
# → docker-compose.yml + docker-compose.db.yml

# Dev environment (base + db + dev)
./script/dockercomposerun -d [CMD]
# → docker-compose.yml + docker-compose.db.yml + docker-compose.dev.yml

# Dev app-only (base + dev, NO db)
./script/dockercomposerun -do [CMD]
# → docker-compose.yml + docker-compose.dev.yml

# App-only no overrides (just base)
./script/dockercomposerun -o [CMD]
# → docker-compose.yml only

# CI environment (base + db + ci config)
./script/dockercomposerun -c [CMD]
# → docker-compose.yml + docker-compose.db.yml + docker-compose.ci.yml

# Performance tests (base + db + dev + perf service)
./script/dockercomposerun -dp [CMD]
# → docker-compose.yml + docker-compose.db.yml + docker-compose.dev.yml + docker-compose.perf.yml
```

**What `-o` Actually Does**:

- **WITHOUT `-o`**: Includes `docker-compose.db.yml` (database service is created)
- **WITH `-o`**: Excludes `docker-compose.db.yml` (app runs standalone)

The `-o` flag is **independent** of `-d`/`-c`:
- `-d` says "use dev environment"
- `-o` says "don't include database service"
- Together `-do` means "use dev image but without database"
- Alone `-o` means "just base configuration (production image without db)"

**When to use `-o`**:
- With `-d`: `./script/dockercomposerun -do` for commands that don't need database (bundle install, lint)
- Alone: `./script/dockercomposerun -o` for running production image without database (rarely used)

### Composition Logic

**Key Insight**: The `dockercomposerun` script builds the docker-compose command by conditionally appending files based on **independent orthogonal flags**.

```bash
# Start with base
docker_compose_command='docker compose -f docker-compose.yml '

# Conditionally add database (UNLESS -o flag is set)
[ -z ${app_only} ] && docker_compose_command="${docker_compose_command} -f docker-compose.db.yml "

# Conditionally add dev overrides (IF -d flag is set)
[ ! -z ${devenv} ] && docker_compose_command="${docker_compose_command} -f docker-compose.dev.yml "

# Conditionally add CI config (IF -c flag is set)
[ ! -z ${ci} ] && docker_compose_command="${docker_compose_command} -f docker-compose.ci.yml "

# Conditionally add perf service (IF -p flag is set)
[ ! -z ${run_perftests} ] && docker_compose_command="${docker_compose_command} -f docker-compose.perf.yml "
```

**Order matters**: Later files override earlier files (docker-compose semantics):
1. `docker-compose.yml` (base - always included)
2. `docker-compose.db.yml` (if `-o` flag NOT set)
3. `docker-compose.dev.yml` (if `-d` flag IS set)
4. `docker-compose.ci.yml` (if `-c` flag IS set)
5. `docker-compose.perf.yml` (if `-p` flag IS set)

### Script Workflow

```
1. Parse flags (-d, -c, -o, -p)
2. Build docker-compose command based on flags
3. Display composed configuration (docker compose config)
4. Pull latest images (docker compose pull)
5. Run composed command with exit code capture
6. Tear down (docker compose down) to clean up
7. Exit with captured return code
```

**Important**: `docker compose down` runs after EVERY execution, cleaning up containers and networks.

---

## Environment Variable System (12-Factor)

### Image Level (Dockerfile ARG/ENV)

```dockerfile
ARG BASE_IMAGE=ruby:4.0.1-slim-trixie
ARG BUNDLER_VERSION=4.0.5
ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_JOBS=4
```

These are build-time and runtime constants in the image.

### Container Level (docker-compose.yml)

```yaml
environment:
  - APP_JWT_SECRET           # App-specific
  - PORT                     # Puma
  - RAILS_ENV                # Rails
  - POSTGRES_HOST            # Database (from docker-compose.db.yml)
  - RAILS_LOG_TO_STDOUT      # Logging
```

**Pattern**: Variables listed but values come from:
1. Host environment (`export SECRET_KEY_BASE=...`)
2. Override file (docker-compose.dev.yml provides defaults)
3. Inline: `APP_IMAGE=rta-dev ./script/dockercomposerun ...`

### Variable Resolution Flow

```
Host ENV → Docker Compose Template → Container ENV
```

Example for `RAILS_ENV`:
- Host: not set (or set to `development`)
- dev.yml: `RAILS_ENV: ${RAILS_ENV:-development}` (default if not set)
- Container: sees `RAILS_ENV=development`

Example for `RAILS_ENV=test` (override):
```bash
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d bash -c 'bundle exec rspec'
```
- Host: `RAILS_ENV=test` is set
- dev.yml: uses the host value (not the default)
- Container: sees `RAILS_ENV=test`

### Database Configuration by Environment

docker-compose.db.yml uses `RAILS_ENV` to isolate databases:

```yaml
POSTGRES_DB: ${POSTGRES_DB:-random_thoughts_api}_${RAILS_ENV:-development}
```

Results:
- Development: `random_thoughts_api_development`
- Test: `random_thoughts_api_test`
- Production: `random_thoughts_api_production`

**Isolation**: Each environment has separate database, preventing test data in production.

---

## Rails Configuration Integration

### config/puma.rb

Reads environment variables:
```ruby
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
port ENV.fetch("PORT", 3000)
```

- Threads: default 3, overridable via `RAILS_MAX_THREADS`
- Port: default 3000, overridable via `PORT`
- Workers: optional via `PUMA_WORKERS` (multi-process mode)

### config/database.yml

Uses environment variables for connection:
```yaml
host: <%= ENV['POSTGRES_HOST'] %>
port: <%= ENV['PGPORT'] %>
database: <%= ENV['POSTGRES_DB'] %>
username: <%= ENV['POSTGRES_USER'] %>
password: <%= ENV['POSTGRES_PASSWORD'] %>
```

- Reads from docker-compose environment variables
- No hardcoded credentials (12-factor)

### config/environments/

Development, test, production configs use `RAILS_ENV` set by container.

---

## GitHub Actions Workflow Integration

### PR Build and Vetting Workflow (on_pr_build_push_vet_images.yml)

The GitHub workflow demonstrates all major uses of the dockercomposerun framework:

**Step 1: Build Images**
```yaml
buildx-and-push-dev-image:
  buildopts: --target devenv
buildx-and-push-unvetted-image:
  buildopts: (default - targets deploy)
```
- Builds both devenv and deploy images from Dockerfile
- Pushes to Docker Hub with branch tags

**Step 2: Code Quality Vetting** (uses `-do` flag - app only)
```yaml
lint_command: "APP_IMAGE=${{ dev_image }} ./script/dockercomposerun -do ./script/run lint"
dependency_security_command: "APP_IMAGE=${{ dev_image }} ./script/dockercomposerun -do ./script/run depsecscan"
static_security_command: "APP_IMAGE=${{ dev_image }} ./script/dockercomposerun -do ./script/run statsecscan"
```
- Uses `-do` (development + app only)
- No database needed for static analysis
- Faster execution: no db startup
- Each command runs in isolated container

**Step 3: Unit Tests** (uses `-d` flag - with database)
```yaml
tests_command: "RAILS_ENV=test APP_IMAGE=${{ dev_image }} ./script/dockercomposerun -d ./script/run tests"
```
- Uses `-d` (development + database)
- Sets `RAILS_ENV=test` for separate test database
- Runs full test suite including database integration tests

**Step 4: API Documentation Vetting**
```yaml
run: "APP_IMAGE=${DEVENV_IMAGE} ./script/dockercomposerun -d ./script/run swaggerize"
```
- Generates Swagger documentation from RSpec tests
- Uses `-d` for development environment
- Validates documentation currency

**Step 5: End-to-End Tests**
- Uses both deployment and dev images
- Tests actual container behavior
- Validates multi-platform builds (amd64, arm64)

### Production Promotion Workflow (on_push_to_main_promote_to_prod.yml)

After PR is merged to main:
- Merges branch image tags to production tags
- Tags images with commit SHA and `:latest`
- Demonstrates immutable production image pattern

### Workflow Implications for dockercomposerun Design

The workflows reveal why certain design decisions were made:

1. **`-do` flag exists**: Workflows need fast linting/security without database overhead
2. **`-d` flag exists**: Different commands need different services (db vs no-db)
3. **`APP_IMAGE` override required**: Workflows need to target specific built images
4. **Automatic teardown essential**: CI can't manually clean up; script handles it
5. **Exit code propagation**: Workflows need accurate pass/fail status



### Workflow 1: Interactive Development

```bash
./script/dockercomposerun -d
```

1. Flags parsed: `-d` (development)
2. Compose includes: base + db + dev overrides
3. Image resolved: `APP_IMAGE` env var OR default dev image
4. Volume mounted: local source → `/app` in container
5. RAILS_ENV: development (from dev.yml default)
6. Database: `random_thoughts_api_development` created
7. Command: `bash` (default from devenv Dockerfile)
8. Result: Interactive shell in container with source code mounted

### Workflow 2: Running Tests

```bash
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

1. Flags parsed: `-d` (development)
2. Env overrides: `APP_IMAGE=rta-dev`, `RAILS_ENV=test`
3. Compose includes: base + db + dev overrides
4. Image resolved: `rta-dev` (local build)
5. RAILS_ENV: test (from host override)
6. Database: `random_thoughts_api_test` created (separate from dev)
7. Volume mounted: local source with config changes
8. Command: `./script/run tests` (uses project's test runner)
9. Result: Tests run against test database
10. Teardown: `docker compose down` removes test database and containers

### Workflow 3: Running Lint/Security (No Database Needed)

```bash
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run lint
```

1. Flags parsed: `-do` (development + app only)
2. Compose includes: base ONLY (no db, no dev overrides)
3. Image resolved: `rta-dev` (local build)
4. RAILS_ENV: development (default if not overridden)
5. Database: NOT created (flag `-o` excludes docker-compose.db.yml)
6. Command: `./script/run lint` (static code analysis)
7. Result: Linting runs without needing database
8. Faster execution: no database startup overhead

### Workflow 4: Running Bundle Install After Gemfile Changes

```bash
# Step 1: Rebuild image with new Dockerfile (if modified)
docker build --no-cache --target devenv -t rta-dev .

# Step 2: Run bundle in rebuilt image
APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install
```

1. Image rebuild captures any Dockerfile changes
2. Flag `-do`: development environment, app only (no db needed for bundle)
3. Command: `bundle install`
4. Volume mount persists Gemfile.lock to native filesystem
5. Result: Gemfile.lock updated with new dependencies, in container's Ruby/OS

### Workflow 5: Running Production Image

```bash
docker build --no-cache -t rta .
docker run -it --rm -p 3000:3000 -e SECRET_KEY_BASE=... -e APP_JWT_SECRET=... rta
```

1. `docker build` targets default `deploy` stage (production image)
2. Image includes app source (no volume mount needed - self-contained)
3. No dev/test gems (smaller image)
4. Runs as `deployer` user (non-root)
5. Default entrypoint: `./entrypoint.sh`
   - Runs migrations
   - Starts Puma server on port 3000

---

## Key Architectural Decisions & Why

### 1. Multi-Stage Builds

**Why**: Separate dev and production concerns
- Dev image: includes all gems, debugging tools, volume mount capability
- Prod image: only production gems, self-contained, optimized

**Benefit**: Same Dockerfile for both, but vastly different final images

### 2. Composable docker-compose Files

**Why**: Different scenarios need different services/configs
- Dev: needs database, volume mount, dev defaults
- Tests: needs database, test environment isolation
- Perf: needs database, performance testing service
- Prod: no dev tools, non-root user

**Benefit**: Single base definition (`docker-compose.yml`), composed for each scenario

### 3. dockercomposerun Script

**Why**: Hides complexity of file composition and teardown
- Users don't need to know which files to compose
- Automatic cleanup (docker compose down)
- Consistent interface regardless of scenario

**Benefit**: Simple flags (`-d`, `-c`, `-o`, `-p`) instead of complex commands

### 4. Volume Mount Binding (Dev Only)

**Why**: Development requires fast feedback loop
- Edit source locally → immediately visible in container
- Gemfile.lock generated in container → persisted to local filesystem

**Benefit**: No rebuild needed for source changes, only for dependency/Dockerfile changes

**Not in production**: Prod image is immutable and self-contained

### 5. Environment-Based Database Isolation

**Why**: Prevent test data corrupting development database
- `RAILS_ENV=development` → separate database
- `RAILS_ENV=test` → separate database
- Each persists independently

**Benefit**: Running tests won't destroy dev data

### 6. Per-Environment Image Override

**Why**: Different scenarios may use different images
- Dev: usually local build (`rta-dev`)
- CI: might pull from registry
- Prod: immutable production image

**Benefit**: `-c` flag can reference any image, including registry images

---

## Common Mistakes & How The System Prevents Them

### Mistake 1: Running old cached image after Dockerfile changes

**Problem**: Changes to Dockerfile aren't picked up
**How system handles it**:
- Must explicitly rebuild: `docker build --no-cache --target devenv -t rta-dev .`
- Script doesn't auto-rebuild - forces intentional action

### Mistake 2: Mixing test data with dev data

**Problem**: Running tests destroys development database
**How system handles it**:
- `POSTGRES_DB` includes `RAILS_ENV` suffix
- `RAILS_ENV=test` creates separate database
- Each environment is isolated

### Mistake 3: Running tests without database

**Problem**: Tests fail trying to connect to database
**How system handles it**:
- Default composition (no `-o` flag) includes `docker-compose.db.yml`
- Database service is automatically started
- `depends_on` ensures app waits for db healthcheck
- Use `-do` only when you explicitly don't need database

### Mistake 4: Port conflicts when running multiple containers

**Problem**: Two containers try to bind same port
**How system handles it**:
- `docker compose down` runs after every execution
- Containers are removed, ports freed
- Multiple sequential runs don't conflict

### Mistake 5: Forgetting to pass `APP_IMAGE` for CI environment

**Problem**: CI compose file has no fallback image
**How system handles it**:
- `docker-compose.ci.yml` requires `APP_IMAGE` (no default)
- Script will fail if missing
- Prevents accidental wrong image

### Mistake 6: Using wrong flags for command needs

**Problem**: Wasting time waiting for database when not needed
**How system handles it**:
- `-do` combination (dev + app-only) for commands that don't need db
- `-d` for commands that do need db
- Clear guidance through flag semantics
### Testing Setup

```bash
# Build image once
docker build --no-cache --target devenv -t rta-dev .

# Run tests (creates separate database)
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d bash -c 'bundle exec rspec'
# Uses: random_thoughts_api_test database
```

### Production Setup

```bash
# 1. Build prod image
docker build --no-cache -t rta .

# 2. Run server
docker run -it --rm \
  -p 3000:3000 \
  -e SECRET_KEY_BASE=actual_key_value \
  -e APP_JWT_SECRET=actual_secret_value \
  rta

# Image contains app source
# Runs as deployer (non-root)
# Only production gems
# Runs migrations and starts Puma
```

---

## Analysis of Existing Documentation

### README.md Coverage

**What it explains well**:
- High-level purpose: "Docker compose framework for operating, developing, and testing"
- Health check endpoints and their purpose
- Port mappings: app 3000, postgres 5432

**What it lacks**:
- No explanation of multi-stage builds
- No mention of devenv vs deploy distinction
- No explanation of `-d`, `-o`, `-c` flags
- No workflow examples
- Generic postgres connection info (but container uses environment variables)

**Usage instructions given**:
```bash
./script/dockercomposerun  # Run server with postgres
```
Simple, works, but doesn't explain flags or variations.

### PREREQUISITES.md

Expected to cover: Docker installation, environment variables needed

### OPERATING.md (referenced in DEVELOPMENT.md)

Expected to cover: Testing, linting, security scanning, swagger generation

### DEVELOPMENT.md Coverage

**What it explains well** (after Rails 8 updates):
- Prerequisites (Docker, SECRET_KEY_BASE, APP_JWT_SECRET)
- How to run interactive development shell
- How to build custom dev image
- How to override `APP_IMAGE` and `APP_SRC`
- Rails 8 specific notes

**What it still lacks**:
- Explanation of `-do` vs `-d` flag differences
- Why `-d` is needed for tests but `-do` for bundle install
- Database isolation between environments
- Why `RAILS_ENV=test` is required when running tests
- Explanation of what docker-compose.db.yml does
- Why `docker compose down` runs after execution

**Good example given**:
```bash
docker build --no-cache --target devenv -t rta-dev .
APP_IMAGE=rta-dev ./script/dockercomposerun -d
```
Correct sequence: rebuild → use with APP_IMAGE

**Missing examples**:
- Running tests with separate database
- Running bundle install
- Running linting without database
- Debugging container issues

### Gap Analysis: What Users Need to Understand

Based on analyzing all documentation, users should understand:

1. **Image Selection**: When to use devenv vs deploy (where)
2. **Flag Usage**: What `-d`, `-do`, `-c`, `-p` mean and when to use each
3. **Database Isolation**: How RAILS_ENV isolates databases
4. **Volume Mounts**: How local edits immediately affect container
5. **Rebuild Requirements**: When and why to rebuild image
6. **Environment Variables**: How 12-factor config flows through system
7. **Teardown Behavior**: Why `docker compose down` runs automatically

Current documentation assumes users can infer these through examples, but doesn't explicitly teach the architecture.



### Check Composed Configuration

```bash
./script/dockercomposerun -d    # Exits before running, but prints config
```

Look at "DOCKER COMPOSE CONFIGURATION..." output to see all files composed.

### Check Environment Variables

```bash
APP_IMAGE=rta-dev ./script/dockercomposerun -do env
```

Lists all environment variables in container.

### Debug Image Build

```bash
docker build --no-cache --target devenv -t rta-dev . --progress=plain
```

Shows each build step in detail.

### Interactive Container Debugging

```bash
APP_IMAGE=rta-dev ./script/dockercomposerun -d bash
# Inside: ruby --version, bundle list, etc.
```

