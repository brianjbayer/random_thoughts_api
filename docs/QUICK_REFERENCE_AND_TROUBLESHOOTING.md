# Quick Command Reference & Troubleshooting

A quick-lookup guide for common development tasks and how to debug issues.

---

## Common Commands

### Development Workflows

```bash
# Initial setup (after cloning)
docker build --no-cache --target devenv -t rta-dev .
APP_IMAGE=rta-dev ./script/dockercomposerun -d bash

# Interactive development shell
APP_IMAGE=rta-dev ./script/dockercomposerun -d

# Running tests (RAILS_ENV=test required, -d flag required for database)
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests

# Running specific test file
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests spec/models/user_spec.rb

# Linting (no database needed)
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run lint

# Security scan
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run depsecscan

# After Gemfile changes (ALWAYS rebuild image first!)
docker build --no-cache --target devenv -t rta-dev .
APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests

# Rails console
APP_IMAGE=rta-dev ./script/dockercomposerun -d ./script/run rails console

# Database migrations
APP_IMAGE=rta-dev ./script/dockercomposerun -d ./script/run rails db:migrate

# Create database
APP_IMAGE=rta-dev ./script/dockercomposerun -d ./script/run rails db:create

# View logs
APP_IMAGE=rta-dev ./script/dockercomposerun -d tail -f log/development.log

# Production-like image (no dev tools)
docker build --no-cache -t rta .
docker run -it --rm -p 3000:3000 \
  -e SECRET_KEY_BASE=your_key \
  -e APP_JWT_SECRET=your_secret \
  -e DATABASE_URL=postgres://user:pass@host/db \
  rta
```

---

## Flag Guide

When using `./script/dockercomposerun`, flags control what gets included:

### Environment Selection (choose ONE)
- `-d`: Use **dev environment** (includes dev gems, volume mounts)
- `-c`: Use **CI environment** (CI-specific config)
- (none): Use **production** image (minimal, no dev tools)

### Services
- `-o`: **App Only** (exclude database service, faster for no-db operations)
- (none): **Include database** (required for tests, migrations, etc.)

### Special
- `-p`: **Perf tests** (run k6 performance tests instead)

### Examples
```bash
# Dev + Database
./script/dockercomposerun -d                      # interactive shell

# Dev + No Database (fast, for lint/security)
./script/dockercomposerun -do ./script/run lint

# CI + No Database (CI image, no dev tools)
./script/dockercomposerun -co ./script/run lint

# Tests (need database, so just -d)
RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests

# Production (no flags, uses production image)
docker run -it rta
```

---

## Environment Variables

### Required
```bash
SECRET_KEY_BASE=your_generated_key           # Rails secret
APP_JWT_SECRET=your_jwt_secret                # API authentication
```

### Important for specific contexts
```bash
RAILS_ENV=development                         # Default (development database)
RAILS_ENV=test                                # For running tests (test database)
RAILS_ENV=production                          # For production deployment

APP_IMAGE=rta-dev                             # Use after rebuilding image
PUMA_WORKERS=0                                # Dev: threads only (default)
PUMA_WORKERS=4                                # Production: 4 worker processes
```

### Database
These are auto-generated in docker-compose based on `RAILS_ENV`:
```bash
DATABASE_URL=postgres://user:password@db:5432/random_thoughts_api_development
# Changes to:
DATABASE_URL=postgres://user:password@db:5432/random_thoughts_api_test
# In production
```

---

## Troubleshooting

### "Bundle install fails with wrong Ruby version"

**Problem**: You edited Gemfile and ran `bundle install` without rebuilding the image.

**Solution**:
```bash
# Step 1: ALWAYS rebuild image first when Gemfile changes
docker build --no-cache --target devenv -t rta-dev .

# Step 2: Then run bundle install in the new image
APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install

# Step 3: Verify tests pass
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

**Why**: Gemfile.lock is always generated in the container (Ruby 4.0.1), never on native macOS.

---

### "Tests fail: 'Could not find X in any of the sources'"

**Problem**: Gemfile.lock was generated with wrong Ruby version (old image).

**Solution**: Same as above—rebuild image with `--no-cache`, then `bundle install`, then test.

---

### "Tests fail: 'Unknown database'"

**Problem**: Running tests with `-do` flag (excludes database service), but tests need database.

**Solution**:
```bash
# WRONG - no database service
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -do ./script/run tests

# CORRECT - includes database service
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

**Remember**: `-d` includes database, `-do` excludes it. Tests NEED database.

---

### "Ports already in use"

**Problem**: Stale containers still running from previous session.

**Solution**:
```bash
# Docker-compose automatically cleans up after commands,
# but if ports still conflict:
docker compose down
docker ps  # verify empty

# Or force stop all containers
docker stop $(docker ps -q)
```

---

### "Changes to code aren't showing up"

**Problem**: Volume mount isn't working, or container is using stale image.

**Solution**:
```bash
# Verify volume mount is working
APP_IMAGE=rta-dev ./script/dockercomposerun -d bash
# Inside container:
ls /app/app/controllers/  # Should show your files

# Check if files are actually changed on disk
git status

# If using wrong image
APP_IMAGE=rta-dev ./script/dockercomposerun -d  # Use correct image
```

---

### "How do I know if I need to rebuild?"

**Rebuild Required** (use `--no-cache`):
- ✅ Changed Dockerfile
- ✅ Changed Gemfile or Gemfile.lock
- ✅ Changed .ruby-version
- ✅ Changed docker-compose files

**Rebuild NOT Required**:
- ❌ Changed Rails app code
- ❌ Changed views, CSS, JavaScript
- ❌ Changed config/environments/*.rb (most changes)
- ❌ Changed database migrations

**When in doubt**, rebuild: `docker build --no-cache --target devenv -t rta-dev .`

---

### "How do I run a single test?"

```bash
# Run specific test file
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests spec/models/user_spec.rb

# Run specific test
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests spec/models/user_spec.rb:42

# Run tests matching pattern
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests --pattern user
```

---

### "How do I debug a failing test?"

```bash
# Add debugging to code, then run with binding.pry
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d bash
# Inside container:
cd /app
bundle exec rspec spec/models/user_spec.rb
# Pauses at binding.pry for debugging
```

---

### "How do I connect to the database?"

```bash
# From inside the container
APP_IMAGE=rta-dev ./script/dockercomposerun -d bash

# Inside container:
psql random_thoughts_api_development  # connects automatically

# Or explicitly:
psql -h db -U postgres -d random_thoughts_api_development
```

---

### "Can I run the app server?"

```bash
# Development server on port 3000
APP_IMAGE=rta-dev ./script/dockercomposerun -d ./script/run server

# Then access at http://localhost:3000
```

---

## When to Check Documentation

| Issue | Check This | Then Try |
|-------|-----------|----------|
| "What's the right command for X?" | OPERATING.md | Then DEVELOPMENT.md |
| "Container command fails" | DOCKER_SYSTEM_ARCHITECTURE.md | Then COPILOT_GUIDES.md section 2b |
| "Tests don't work" | DEVELOPMENT.md (corrected section) | Then this troubleshooting guide |
| "What changed in Rails 8?" | DEVELOPMENT.md (Rails 8 notes) | Then Gemfile |
| "How should I make a change?" | COPILOT_GUIDES.md | Then AI_ASSISTANCE_SESSION_ANALYSIS.md |
| "What else breaks if I change X?" | DEPENDENCIES.md | Then COPILOT_GUIDES.md section 21 |

---

## Common Test Scenarios

### Running all tests
```bash
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

### Only model tests
```bash
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests spec/models
```

### Only request/integration tests
```bash
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests spec/requests
```

### Running linter before commit
```bash
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run lint
```

### Running security checks
```bash
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run depsecscan
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run brakeman
```

### Full test suite (lint + security + tests)
```bash
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run lint
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run depsecscan
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

---

## Production-Like Testing

To test the production image locally:

```bash
# Build production image
docker build --no-cache -t rta .

# Generate a secret (for testing only)
SECRET_KEY_BASE=$(openssl rand -hex 32)
APP_JWT_SECRET=$(openssl rand -hex 16)

# Run with test database setup
docker run -it --rm \
  -p 3000:3000 \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=$SECRET_KEY_BASE \
  -e APP_JWT_SECRET=$APP_JWT_SECRET \
  -e DATABASE_URL=postgres://postgres:password@host.docker.internal:5432/test_db \
  rta
```

Note: Production image doesn't include test gems or development tools. If it fails to start, you probably edited the Dockerfile incorrectly.

---

## Checking Container Image

```bash
# View currently built images
docker images | grep rta

# Check what's in an image
docker run -it rta-dev ls /app/app/controllers
docker run -it rta-dev bundle list | grep rails

# Check Ruby version in image
docker run -it rta-dev ruby -v

# Inspect layers
docker history rta-dev
```

---

## Emergency: "I messed something up"

### Option 1: Clean rebuild
```bash
# Remove local image
docker rmi rta-dev

# Rebuild from scratch (might take a few minutes)
docker build --no-cache --target devenv -t rta-dev .

# Test it
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

### Option 2: Revert Gemfile
```bash
# If you changed Gemfile and broke things
git checkout Gemfile
git checkout Gemfile.lock

# Rebuild
docker build --no-cache --target devenv -t rta-dev .
APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install
```

### Option 3: Start over completely
```bash
# Stop all containers
docker compose down
docker stop $(docker ps -q)

# Remove all containers related to this project
docker ps -a | grep rta | awk '{print $1}' | xargs docker rm

# Remove image
docker rmi rta-dev

# Clean git
git checkout HEAD -- .
git clean -fd

# Rebuild everything
docker build --no-cache --target devenv -t rta-dev .
APP_IMAGE=rta-dev ./script/dockercomposerun -d bash
```

---

## Related Documentation

- **DEVELOPMENT.md** - Detailed dev setup and workflows
- **OPERATING.md** - Production operations and monitoring
- **DOCKER_SYSTEM_ARCHITECTURE.md** - Why the system is designed this way
- **COPILOT_GUIDES.md** - Guidelines for AI-assisted development
- **DEPENDENCIES.md** - What breaks when you change things
- **AI_ASSISTANCE_SESSION_ANALYSIS.md** - Session learnings and guidelines
