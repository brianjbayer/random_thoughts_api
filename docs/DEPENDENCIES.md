# Change Dependency Graph

This document maps how changes in one area cascade to other areas. Understanding these dependencies prevents overlooked impacts.

## Gemfile Changes → Required Actions

**When you modify Gemfile:**
- ✅ REQUIRED: Regenerate Gemfile.lock IN container environment
  - Command: `./script/dockercomposerun -do bundle install`
  - Result: Gemfile.lock reflects container Ruby 4.0.1 + Debian environment
  - Exit code must be: 0

- ⚠️ MAY REQUIRE: Update config/environments/default.rb
  - If gem adds new configuration (e.g., JWT secrets, Redis)

- ⚠️ MAY REQUIRE: Update docs/DEVELOPMENT.md
  - If gem introduces new environment variables
  - If gem affects development workflow

- ⚠️ MAY REQUIRE: Update .ruby-version or Dockerfile Ruby version
  - If gem requires specific Ruby version

**Examples:**
- Adding Rails 8.0.0: Updates Gemfile.lock, may update config/load_defaults (if requested separately)
- Adding web-console: Adds to development group only, no other changes needed
- Adding JWT gem: Updates Gemfile.lock, may require config changes for JWT_SECRET handling

---

## Dockerfile Changes → What Breaks

**When you modify devenv-builder stage:**
- ✅ AFFECTS: Local development environment (`./script/dockercomposerun -d`)
- ✅ AFFECTS: Developer experience, gem availability, debugging tools
- ⚠️ CHECK: Does change respect devenv-builder's PURPOSE? (Must include test gems, dev tools)
- ⚠️ CHECK: Is the same pattern needed in deploy-builder? (Usually NO)

**When you modify deploy-builder stage:**
- ✅ AFFECTS: Production image size, gem bundle, security
- ✅ AFFECTS: CI builds, production deployment
- ⚠️ CHECK: Does this break devenv-builder? (Unlikely, but verify)

**When you modify base-builder stage:**
- ✅ AFFECTS: BOTH devenv and deploy builders (inherits from here)
- ✅ AFFECTS: Build time, package availability
- ⚠️ MUST CHECK: Does change work for both development AND production?

**When you add ENV variables to Dockerfile:**
- ✅ AFFECTS: Container build and runtime behavior
- ⚠️ MAY REQUIRE: Update docker-compose.yml to pass the variable
- ⚠️ MAY REQUIRE: Update docs/PREREQUISITES.md if developer-facing
- ⚠️ MAY REQUIRE: Update docs/DEVELOPMENT.md Rails notes if environment-specific

---

## config/application.rb Changes → Propagation

**When you modify config/application.rb:**
- ✅ AFFECTS: All environments (unless overridden)
- ⚠️ CHECK: Does config/environments/default.rb override this?
- ⚠️ CHECK: Is this intentional for all environments?

**When you change config.load_defaults:**
- ✅ AFFECTS: All Rails 8 behavior defaults
- ⚠️ MUST VERIFY: This was requested separately (not bundled with other changes)
- ⚠️ MUST CHECK: Does this require config/environments updates?

---

## config/puma.rb Changes → Testing Requirements

**When you add or modify Puma configuration:**
- ✅ AFFECTS: Server startup and behavior
- ✅ AFFECTS: Thread count, worker count, memory usage
- ⚠️ MUST TEST: Both thread mode and worker mode if ENV-based
  - Command: `./script/dockercomposerun -d` (default threads)
  - Command with ENV: `PUMA_WORKERS=2 ./script/dockercomposerun -d`
- ⚠️ MAY REQUIRE: Update docs/DEVELOPMENT.md with new ENV variables
- ⚠️ MAY REQUIRE: Update docker-compose files if using env variables

---

## config/environments/default.rb Changes → Scope

**When you add Rails 8 configurations:**
- ✅ AFFECTS: All environments (applied before environment-specific overrides)
- ⚠️ CHECK: Are environment-specific configs already handling this? (Check production.rb, development.rb)
- ⚠️ CHECK: Will this break any existing environment-specific settings?

**When you add environment variable-based config:**
- ✅ AFFECTS: Runtime behavior dependent on ENV
- ⚠️ MUST DOCUMENT: In docs/DEVELOPMENT.md Rails 8 Specific Notes
- ⚠️ MUST VERIFY: ENV variable is actually set in docker-compose files

---

## Environment Variables → Documentation & Deployment

**When you add a new ENV variable:**
- ✅ AFFECTS: Documented in: config file where it's used
- ✅ AFFECTS: Documented in: docs/DEVELOPMENT.md
- ✅ AFFECTS: Documented in: docs/PREREQUISITES.md (if developer-facing)
- ✅ AFFECTS: Must be set in: docker-compose.yml or docker-compose.dev.yml
- ✅ AFFECTS: May be needed in: production deployment scripts

**ENV variables by category:**
- **Required**: SECRET_KEY_BASE, APP_JWT_SECRET (must fail if missing)
- **Optional**: RAILS_LOG_TO_STDOUT, RAILS_ASSUME_SSL (defaults provided)
- **Container/Dev**: PUMA_WORKERS, DATABASE_POOL_SIZE (affects runtime)
- **Tuning**: RAILS_MAX_THREADS, BUNDLE_JOBS (performance)

---

## Documentation Changes → Cascading Updates

**When you update docs/DEVELOPMENT.md:**
- ✅ AFFECTS: Developer onboarding and understanding
- ⚠️ CHECK: Is this consistent with actual code? (Verify against source files)

**When you add new docs/CONSTRAINTS.md entry:**
- ✅ AFFECTS: Future AI-assisted changes (constraints are enforced)
- ✅ AFFECTS: Developer understanding of WHY decisions were made

**When you update docs/ARCHITECTURE.md:**
- ✅ AFFECTS: Multi-stage system changes (must check against architecture first)
- ✅ AFFECTS: Prevents misunderstandings like adding BUNDLE_WITHOUT to wrong stage

---

## Cross-Cutting: Rails Version Upgrades

Rails upgrades affect MULTIPLE areas. Must be coordinated:

| Area | Action | When | Why |
|------|--------|------|-----|
| Gemfile | Change version constraint | Step 1 | Base of upgrade |
| Container | Run bundle install | Step 2 | Lock file must reflect container Ruby |
| config/application.rb | OPTIONALLY update load_defaults | Step 3 ONLY IF REQUESTED | Major config change |
| Tests | Run test suite | Step 3 | Catch breaking changes |
| docs/DEVELOPMENT.md | Add Rails version notes | Step 4 | Document new features/constraints |
| Gemfile.lock | Commit | Step 5 | Final artifact |

**Never bundle all at once.** Each step should be:
1. Testable independently
2. Verifiable (success criteria)
3. Revertible if it breaks

---

## How to Use This Document

**Before suggesting a change:**
1. Identify what you're changing (Gemfile, Dockerfile, config, env var)
2. Find its row in this document
3. Check all cascading impacts
4. Document which impacts apply to THIS change
5. Only suggest if you understand and can handle all impacts

**Example:**
"I'm suggesting change to config/puma.rb:
- Direct impact: Server startup behavior
- Cascades to: docs/DEVELOPMENT.md (ENV variable documentation)
- Must test: With PUMA_WORKERS=0 and PUMA_WORKERS=2
- Affects: Container startup and performance
- Documentation needed: Add to Rails 8 notes section"

If you can't articulate all cascades, escalate instead of suggesting.
