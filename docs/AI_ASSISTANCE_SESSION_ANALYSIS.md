# AI Assistance Session Analysis & Comprehensive Guidance

This document consolidates learnings from this Rails 8 upgrade session and establishes authoritative AI-assistance practices for this project.

---

## Part 1: Session Mistakes & Root Causes

### Mistake 1: Container-First Violations

**What I Did Wrong**:
- Suggested `./script/dockercomposerun -do bundle install` immediately after Gemfile changes
- Did NOT explicitly require `docker build --no-cache --target devenv -t rta-dev .` first
- Attempted to run tests without accounting for stale image

**Root Cause**:
- Documented "container-first principle" but didn't apply it to my own suggestions
- Assumed image rebuild would happen automatically (it doesn't)
- Didn't verify actual workflow by checking GitHub Actions usage

**What Should Have Happened**:
1. Read Dockerfile to understand multi-stage build
2. Check GitHub Actions workflows to see how they handle builds
3. Verify: "What image is being used? Is it rebuilt after changes?"
4. THEN suggest complete workflow: rebuild → use APP_IMAGE

**Learning**: Document principles, then apply them to EVERY suggestion. If suggesting a container command, ask: "Is the image current?"

---

### Mistake 2: Not Recognizing Orthogonal Flags

**What I Did Wrong**:
- Treated `-o` flag as "only for use with `-d`"
- Called it `-do` (app-only-dev) instead of understanding it as two independent flags
- Didn't verify flag logic in script

**Root Cause**:
- Read the script but didn't fully parse the conditional logic
- Assumed flags were hierarchical instead of orthogonal
- Didn't check how flags were actually used in workflows

**What Should Have Happened**:
1. Read dockercomposerun script carefully
2. Trace through logic: `[ -z ${app_only} ] && add_db`
3. Understand: "If app_only is empty, add db. If app_only=1, don't add db"
4. Test understanding: "What does `-do` actually mean?" → "-d (dev env) AND -o (no db)"
5. Verify: Check workflows to confirm both use cases

**Learning**: For scripts, trace conditional logic explicitly. Flags are often orthogonal; don't assume hierarchy.

---

### Mistake 3: Rails Framework Requirements Not Applied

**What I Did Wrong**:
- Didn't include `RAILS_ENV=test` in initial test command suggestions
- Suggested `./script/dockercomposerun -do bundle exec rspec` without RAILS_ENV
- Later added RAILS_ENV but only after user correction
- Put RAILS_ENV in wrong position initially

**Root Cause**:
- Didn't check existing OPERATING.md or script/run for Rails patterns
- Assumed RSpec would work with default environment
- Didn't verify Rails environment variable requirements

**What Should Have Happened**:
1. Recognize: "This is a Rails project"
2. Check: What environment variables are critical?
3. Read OPERATING.md: "If using same db for dev/test, run `./script/run rails db:environment:set RAILS_ENV=test` first"
4. Read script/run: Tests use `${APP_RUN_TESTS_CMD}`
5. Understand: `RAILS_ENV=test` is REQUIRED for Rails, not optional
6. Include in suggestions: `RAILS_ENV=test APP_IMAGE=rta-dev ./script/dockercomposerun ...`

**Learning**: For Rails projects, `RAILS_ENV` is mandatory. Check OPERATING.md early and often.

---

### Mistake 4: Test Command Wrong in Documentation

**What I Put in DEVELOPMENT.md**:
```bash
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -do bundle exec rspec
```

**Problem**:
- Used `-do` (app-only, NO database)
- Tests need database to run
- Should have been `-d` for tests

**Correct**:
```bash
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

**Root Cause**:
- Didn't understand `-do` vs `-d` distinction
- Assumed bundle exec commands don't need db
- Should have used `./script/run tests` (project's test wrapper) not direct rspec call

**What Should Have Happened**:
1. Check OPERATING.md: "Run tests with `./script/run tests`"
2. Trace: script/run maps `tests` command to `rspec`
3. Understand: Tests need database (models, integration tests)
4. Use `-d` for testing: `./script/dockercomposerun -d ./script/run tests`
5. Use `-do` for lint/security: `./script/dockercomposerun -do ./script/run lint`

**Learning**: Different commands need different docker-compose compositions. Check the project's command wrapper (script/run) for canonical invocation.

---

### Mistake 5: Incomplete Workflow Documentation

**What I Did Wrong**:
- Documented "rebuild image" but didn't connect it to "using the image"
- Suggested commands without `APP_IMAGE=rta-dev` prefix
- Didn't show complete end-to-end workflow
- Assumed users would connect the dots

**Root Cause**:
- Focused on individual commands instead of workflows
- Didn't trace full sequences
- Didn't verify against GitHub Actions examples

**What Should Have Happened**:
1. Identify workflow steps:
   - Edit Gemfile (local filesystem)
   - Rebuild image (docker build)
   - Run commands with image (dockercomposerun with APP_IMAGE)
2. Show complete sequence with all variables
3. Compare against GitHub Actions to validate
4. Document failure modes: "If you don't set APP_IMAGE, which image runs?"

**Learning**: Document workflows, not commands. Show the complete sequence with all dependencies.

---

## Part 2: Project Patterns & Idioms Analysis

### Pattern 1: Script Wrapping

This project uses **two-level script wrapping**:

**Level 1**: `script/dockercomposerun` - Docker Compose orchestration
- Handles file composition based on flags
- Manages image selection via `APP_IMAGE` env var
- Handles cleanup (docker compose down)
- Wraps container execution and return codes

**Level 2**: `script/run` - Command execution
- Maps friendly commands to actual tool invocations
- Allows environment variable overrides
- Standardizes test/lint/security commands
- Supports both containerized and native execution

**AI Implication**:
- Always use `./script/run [command]` when available, not raw tool invocations
- Examples: `./script/run tests`, `./script/run lint`, `./script/run depsecscan`
- Avoid suggesting `bundle exec rspec` directly; use `./script/run tests`
- These scripts document the canonical invocation

---

### Pattern 2: Multi-Stage Container Architecture

**Three container use cases**:

1. **Interactive Development** (`-d`)
   - Image: devenv (with all gems)
   - Volume: local code mounted
   - Database: included
   - Purpose: Edit code, run commands interactively

2. **Quick Operations** (`-do`)
   - Image: devenv (with all gems)
   - Volume: local code mounted
   - Database: NOT included
   - Purpose: Lint, security scan, bundle operations (fast execution)

3. **Production** (none, direct `docker run`)
   - Image: deploy (production only)
   - Volume: NOT used (self-contained)
   - Database: external
   - Purpose: Immutable deployable artifact

**AI Implication**:
- Distinguish between these three use cases
- Don't conflate development and production workflows
- Understand that prod image is immutable; changes in dev image don't affect prod
- Reference correct image/stage for each operation

---

### Pattern 3: Environment Variable Inversion

Container is source of truth, not native OS:

**Wrong Thinking**:
- "Ruby 4.0.1 is installed on my Mac? Check."
- "Run bundle install natively"
- Result: Gemfile.lock doesn't match container

**Right Thinking**:
- "What Ruby/OS is in the container?"
- "That's the source of truth for dependencies"
- "Generate Gemfile.lock in the container"
- Result: Dev and prod have identical Gemfile.lock

**AI Implication**:
- Never suggest native commands for dependency management
- Always: "This runs in the container, so generate in the container"
- Check: `config/database.yml` uses ENV variables, not hardcoded values
- Verify: All critical configs are 12-factor (environment-driven)

---

### Pattern 4: Rails Environment Isolation

**Three databases, one schema**:

```yaml
POSTGRES_DB: random_thoughts_api_${RAILS_ENV}
```

Results in:
- `random_thoughts_api_development` (edit/test code)
- `random_thoughts_api_test` (tests don't corrupt dev data)
- `random_thoughts_api_production` (live data)

**AI Implication**:
- `RAILS_ENV=test` is not optional—it's required to use separate database
- Never run tests with RAILS_ENV unset (would use development db)
- Different `./script/run` invocations use different databases automatically
- Workflows must set RAILS_ENV correctly

---

### Pattern 5: Orthogonal Flag Design

The dockercomposerun script is designed around orthogonal concerns:

| Concern | Flags | Meaning |
|---------|-------|---------|
| **Environment** | `-d`, `-c` | Which image/config to use |
| **Services** | `-o` | Include database service or not |
| **Additional** | `-p` | Run perf tests instead of app |

**Orthogonal = Independent**:
- `-d -o` = dev image WITHOUT database
- `-d` = dev image WITH database
- `-c -o` = CI image WITHOUT database
- `-p -d` = perf tests WITH dev image and database

**AI Implication**:
- Don't assume flags are hierarchical
- Understand each flag's independent purpose
- Combine flags based on what's actually needed
- Workflows use different combinations for different tasks

---

## Part 3: Complete AI-Assistance Framework

### Framework Rule 1: Verification Before Suggestion

**When suggesting ANY change**:

```
1. READ existing code/docs (don't assume)
   - What exists?
   - How is it currently done?
   - What patterns are established?

2. CHECK dependencies
   - What other files does this affect?
   - What environment variables?
   - What build/runtime requirements?

3. REFERENCE real-world usage
   - How do workflows use this?
   - What does script/run do?
   - What does production do?

4. TRACE the complete path
   - Local edit → Container change → Result
   - Don't stop at the intermediate step

5. VERIFY against project rules
   - Container-first?
   - RAILS_ENV correct?
   - Using script wrappers?
   - 12-factor principles?
```

**Implementation**:
- Always run verification queries BEFORE suggesting changes
- Reference specific files and line numbers
- Compare suggestion against actual patterns
- Never suggest "follow the pattern I see" without confirming the pattern

---

### Framework Rule 2: Container-First Workflow

**Every container-related suggestion must include**:

```
Step 1: Edit files locally
  - What file(s) are being changed?
  - Why does this require container rebuild?

Step 2: Rebuild image (if needed)
  - docker build --no-cache --target [STAGE] -t [TAG] .
  - Why --no-cache? (picks up changes)
  - Which stage? (devenv or deploy)

Step 3: Verify image
  - What should be different in the new image?
  - How can user verify? (docker run -it, inspect layers)

Step 4: Run commands with image
  - APP_IMAGE=[TAG] ./script/dockercomposerun [FLAGS] [CMD]
  - Which flags? (-d, -do, -c, -o, -p)
  - Why those flags?

Step 5: Verify results
  - Success criteria?
  - How to check output?
```

**Never suggest**:
- Container commands without mentioning image status
- Gemfile changes without Gemfile.lock regeneration
- Using stale/default images when custom image is needed

---

### Framework Rule 3: Rails Environment Awareness

**Every suggestion involving Rails must address**:

```
1. Is RAILS_ENV correct for this operation?
   - development (default, dev data)
   - test (separate db, test data)
   - production (live data, immutable code)

2. Will this operation access the database?
   - If yes: Does RAILS_ENV match the right database?
   - If no: Can use -do flag to skip database service

3. Does environment variable propagation matter?
   - Set on host: RAILS_ENV=test
   - Container receives: passes through docker-compose
   - Rails reads: uses to select config
   - App behavior: differs per RAILS_ENV

4. Are there environment-specific configs?
   - config/environments/[RAILS_ENV].rb
   - Database isolation
   - Secret management
```

**Common Rails Environment Mistakes**:
- Running tests with `RAILS_ENV=development` (uses wrong database)
- Forgetting `RAILS_ENV=test` in setup (migrations fail silently)
- Not isolating test data (tests corrupt development database)

---

### Framework Rule 4: Documentation Cross-Reference

**Always check existing documentation first**:

| Task | Primary Doc | Secondary |
|------|------------|-----------|
| Running tests | OPERATING.md | DEVELOPMENT.md |
| Developing locally | DEVELOPMENT.md | DOCKER_SYSTEM_ARCHITECTURE.md |
| Running linting | OPERATING.md | script/run |
| Container patterns | DOCKER_SYSTEM_ARCHITECTURE.md | Dockerfile |
| Database setup | OPERATING.md | docker-compose.db.yml |
| Environment variables | DEVELOPMENT.md | config/* files |
| Debugging | DOCKER_SYSTEM_ARCHITECTURE.md | script/dockercomposerun |

**Never**:
- Duplicate information from OPERATING.md in DEVELOPMENT.md
- Suggest commands that differ from OPERATING.md
- Document outdated patterns

---

## Part 4: Consolidated Documentation Strategy

### Problem: Fragmented Documentation

Current state:
- README.md: High-level, generic
- DEVELOPMENT.md: Local dev setup
- OPERATING.md: Running commands
- DOCKER_SYSTEM_ARCHITECTURE.md: Deep technical details
- COPILOT_GUIDES.md: AI assistance rules
- Inline comments in scripts

Gaps:
- README doesn't explain flag semantics
- DEVELOPMENT.md duplicates OPERATING.md commands
- OPERATING.md doesn't explain container concepts
- DOCKER_SYSTEM_ARCHITECTURE.md is too detailed for quick reference
- COPILOT_GUIDES.md is for AI, not humans

### Solution: Documentation Hierarchy

**Level 1: Quick Reference (README.md)**
- How to run the app
- How to run tests
- Links to detailed docs
- No deep explanation

**Level 2: Developer Workflow (DEVELOPMENT.md)**
- Setting up development environment
- Common development tasks
- Troubleshooting dev issues
- Reference actual CLI examples from script/run output

**Level 3: Operations Guide (OPERATING.md)**
- Running commands (`./script/run [command]`)
- Monitoring health
- Backup/restore
- Scaling (not applicable yet)

**Level 4: Architecture Deep-Dive (DOCKER_SYSTEM_ARCHITECTURE.md)**
- For developers who need to understand HOW
- For debugging infrastructure issues
- Technical decision rationale
- Design patterns and tradeoffs

**Level 5: AI Assistance Rules (COPILOT_GUIDES.md)**
- For AI assistants working on this project
- Framework for making suggestions
- Common mistakes and prevention
- Domain knowledge required

### Immediate Documentation Fixes

**1. Consolidate Duplicate Test Instructions**

Current state:
- OPERATING.md: `./script/run tests`
- DEVELOPMENT.md: `APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests`

Fix: DEVELOPMENT.md should reference OPERATING.md:
> "For complete list of commands, see OPERATING.md. For containerized development, prepend commands with `APP_IMAGE=rta-dev` and use appropriate flags."

**2. Document Flag Matrix**

Add to DOCKER_SYSTEM_ARCHITECTURE.md as reference card:

```
COMMON COMMAND PATTERNS:

Interactive Dev:
  APP_IMAGE=rta-dev ./script/dockercomposerun -d bash

Run Tests:
  APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests

Run Lint (no db):
  APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run lint

Bundle Install (no db):
  APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install

Production Image:
  docker build --no-cache -t rta .
  docker run -it --rm -p 3000:3000 -e SECRET_KEY_BASE=... -e APP_JWT_SECRET=... rta
```

**3. Document Container vs Native**

Add to README:
> "All development is containerized. Do NOT run bundle install, tests, or rake commands on native macOS; use the container via ./script/dockercomposerun"

**4. Document When to Rebuild**

Add to DEVELOPMENT.md "Building Custom Images" section:

```
When MUST you rebuild?
✓ Changed Dockerfile
✓ Changed Gemfile
✓ Changed Ruby version
✓ Changed base Docker image

When is rebuild optional?
✗ Changed Rails app code (no rebuild needed)
✗ Changed CSS/JS (no rebuild needed)
```

---

## Part 5: Authoritative AI-Assistance Practices

### Rule 1: Explicit Verification Queries

Before suggesting a change, always:

```
1. [ ] Read the file being modified
2. [ ] Check existing patterns in related files
3. [ ] Verify against documentation
4. [ ] Cross-reference with scripts
5. [ ] Trace complete workflow
```

Example:
```
❌ WRONG: "Update config/puma.rb to add X"
✅ RIGHT:
  - Read current config/puma.rb (lines 1-43)
  - Check how similar projects configure puma
  - Verify against DEVELOPMENT.md documented behavior
  - Show before/after with specific line numbers
```

### Rule 2: Container-First Default

**Every suggestion involving**:
- Dependencies (Gemfile, package.json, requirements.txt)
- Build artifacts (images, compiled code)
- Runtime environment (Ruby version, system packages)
- Tests or production behavior

**Must address**:
- Is an image rebuild needed?
- If yes: show rebuild step with --no-cache
- If no: explain why not
- Include APP_IMAGE= in commands when using custom image

### Rule 3: Rails Framework Consciousness

**Every Rails project suggestion must include**:
- Correct RAILS_ENV for the operation
- Database availability requirements (does it need `-d` or `-do`?)
- Whether to use `./script/run [command]` wrapper
- Environment variable propagation

### Rule 4: Documentation-Driven Suggestions

**Hierarchy for determining correct approach**:

```
1. What does existing code do?
2. What does the project's own script/run do?
3. What does OPERATING.md say?
4. What does DEVELOPMENT.md say?
5. What does DOCKER_SYSTEM_ARCHITECTURE.md say?
6. What does the Dockerfile/docker-compose do?
7. Only then: What does the Rails/Ruby documentation say?
```

**Never** suggest something that contradicts project documentation.

### Rule 5: Complete Workflow Suggestions

**Never suggest**:
- Just the command
- Just the file change
- Just one step of a multi-step process

**Always show**:
- Prerequisite checks ("Is image current?")
- Complete command sequence
- Expected output/results
- How to verify success
- How to debug if it fails

---

## Part 6: Session Accomplishments

Despite mistakes, the session established:

1. ✅ Correct Rails 8.0.4 in Gemfile (upgraded from 7.2.2.1)
2. ✅ Correct Gemfile.lock generation in container
3. ✅ Fixed invalid Rails 8 config methods
4. ✅ Added timezone configuration for Rails 8.1
5. ✅ Verified all 250 tests pass
6. ✅ Created comprehensive DOCKER_SYSTEM_ARCHITECTURE.md
7. ✅ Documented container-first workflow in COPILOT_GUIDES.md
8. ✅ Added `-o` flag orthogonality explanation
9. ✅ GitHub workflow analysis
10. ✅ Documentation gap analysis

---

## Part 7: Moving Forward

### Immediate Actions

1. **Update COPILOT_GUIDES.md** with consolidated session learnings
2. **Create quick-reference card** for common dockercomposerun patterns
3. **Update DEVELOPMENT.md** to avoid duplicating OPERATING.md
4. **Add "Container-First Checklist"** for code review
5. **Document failure modes** for common mistakes

### For Future AI Assistance

When working on this project:

1. **Include in prompt**: `Follow the AI Guidelines section in docs/COPILOT_GUIDES.md`
2. **Reference this session**: `See docs/AI_ASSISTANCE_SESSION_ANALYSIS.md for framework`
3. **Check these first**: README → DEVELOPMENT → OPERATING → DOCKER_SYSTEM_ARCHITECTURE
4. **Assume**: Container-first, Rails-aware, verification-driven
5. **Verify**: Image status, RAILS_ENV, flag combinations, script wrappers

### Success Criteria

AI assistance is working well when:

```
✓ Suggestions include complete workflows, not isolated commands
✓ Container rebuilds are explicit prerequisites
✓ RAILS_ENV is correct for each operation
✓ Script wrappers are used (./script/run, ./script/dockercomposerun)
✓ Documentation contradictions are surfaced, not ignored
✓ Verification steps precede suggestions
✓ Failure modes are documented
✓ Tests pass before declaring success
```

---

## Appendix: Project Technical Stack Reference

**Framework & Language**:
- Rails 8.0.4
- Ruby 4.0.1 (container)
- PostgreSQL 15+ (container)

**Build & Deployment**:
- Multi-stage Dockerfile (devenv & deploy)
- Docker Compose (dev & test)
- GitHub Actions (CI/CD)
- Docker Hub (image registry)

**Development Tools**:
- RSpec (testing)
- Rubocop (linting)
- Brakeman (security)
- Bundler-audit (dependency security)
- RSwag (API documentation)

**Architecture**:
- Container-first development
- 12-factor configuration
- JWT authentication
- API versioning (v1)
- Health checks (livez/readyz)

**Patterns**:
- Script wrappers (script/run, script/dockercomposerun)
- Orthogonal flag design
- Environment isolation (dev/test/prod databases)
- Volume mount binding (local code → container)
- Immutable production images

