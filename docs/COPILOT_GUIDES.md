# Copilot Guidelines

These guidelines ensure reliable, non-hallucinating AI-assisted development. Include `docs/COPILOT_GUIDES.md` in prompts for consistent quality.

**For comprehensive analysis of this session and how it informed these guidelines, see [docs/AI_ASSISTANCE_SESSION_ANALYSIS.md](AI_ASSISTANCE_SESSION_ANALYSIS.md).**

---

## ⭐ PRE-SUGGESTION VERIFICATION CHECKLIST

**Before suggesting ANY change, complete this checklist**:

- [ ] **Understand the change type**. What are you suggesting?
  - Dependency change? → Section 13, 20
  - Container/Docker change? → Section 2b, 14, 15, 16
  - Rails config? → Section 11, 14, 17
  - API contract? → Section 8, 10

- [ ] **Read the existing code/files** related to this change
  - Use grep_search, read_file, or semantic_search
  - Don't suggest changes to files you haven't read
  - Reference actual line numbers when citing code

- [ ] **Verify against project patterns**
  - Does similar logic exist elsewhere?
  - Does this follow established idioms?
  - Is this inconsistent with how the project does things?

- [ ] **Check documentation first**
  - README.md → DEVELOPMENT.md → OPERATING.md → DOCKER_SYSTEM_ARCHITECTURE.md
  - Never suggest contradicting project docs
  - If docs are wrong, surface that issue—don't ignore it

- [ ] **Trace the complete workflow**
  - Local edit → container build → runtime execution → result
  - Don't suggest intermediate steps without showing the whole flow
  - Include prerequisite steps (like image rebuilds)

- [ ] **For container commands**: Is the image current?
  - Did Dockerfile or Gemfile change? → Image needs rebuild
  - Section 2b has the complete workflow
  - Include `docker build --no-cache --target [stage] -t [tag] .` in suggestions

- [ ] **For Rails commands**: Is RAILS_ENV correct?
  - Tests need `RAILS_ENV=test`
  - Development work uses `RAILS_ENV=development` (default)
  - Production is immutable (no env var change)

- [ ] **Declare assumptions** (Section 19)
  - Write: "I'm assuming [assumption]. Verified: [yes/no/source]"
  - If unverified, ask for confirmation before proceeding
  - Don't hide assumptions in suggestions

- [ ] **Map impacts** (Section 20)
  - See docs/DEPENDENCIES.md for change cascades
  - List all affected components
  - Verify you can handle each impact

**Only proceed with suggestion after ALL items are addressed.**

---

## 1. VERIFICATION FIRST - Always Check Before Suggesting

- Always check actual files/code before suggesting changes
- Use `read_file`, `grep_search`, or `semantic_search` to confirm patterns exist
- Never assume file structure or content—verify it
- Reference actual line numbers and exact code snippets
- Check the current state of files before proposing modifications
- If documentation contradicts code, surface the discrepancy and resolve it

## 2. UNDERSTAND RUNTIME ENVIRONMENT & ARCHITECTURE ⭐

**Critical before suggesting technical changes:**
- Understand how the application deploys (containers, servers, cloud, local)
- Know the actual runtime environment's version constraints (container OS, Ruby version, etc.)
- Recognize where code/configuration runs vs. where it's edited
- Distinguish between local development, containerized environment, and production
- Understand tool interactions (e.g., volume mounts, file bindings, environment variables)

**Example**: Don't suggest Gemfile changes based on native OS Ruby version—it must be generated in the container environment where the app runs. See Section 13 & 14 for container-specific guidance.

## 2a. CHANGE ISOLATION - Make Small, Verifiable Changes ⭐

When upgrading or modifying, never bundle multiple changes together:

**Wrong**: Upgrade Rails + add gems + update config all at once
**Right**:
1. Upgrade Rails only → verify build
2. Add gems only → verify bundle
3. Update config only → verify runtime

Each step should:
- Be testable independently
- Have clear success criteria
- Be easily revertible if it breaks

Document change order in commit messages.

Reference: See docs/DEPENDENCIES.md for what each type of change cascades to.

## 2b. CONTAINER IMAGE REBUILD PREREQUISITE - Never Run Container Commands Against Stale Images ⭐⭐⭐

**CRITICAL**: When Dockerfile or dependency files change (Gemfile, package.json, etc.), you MUST rebuild the container image BEFORE running any commands in that container.

**Problem**: If you run container commands against a stale image, you get:
- Old cached layers with outdated versions
- Gemfile.lock generated with wrong Ruby/gem versions
- Stale environment configurations
- Tests running against old dependencies

**The Complete Workflow**:

```bash
# Step 1: Edit Gemfile, Dockerfile, or dependency files (locally)
# Example: Update Gemfile "gem 'rails', '~> 8.0.0'"
# Example: Update Dockerfile RUN statements

# Step 2: REBUILD the image BEFORE running anything in it
docker build --no-cache --target devenv -t rta-dev .

# Step 3: NOW run container commands with the rebuilt image
APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install

# Step 4: For subsequent container commands, always use the image
# For development work:
APP_IMAGE=rta-dev ./script/dockercomposerun -d

# For running tests (RAILS_ENV=test is required):
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

**Critical**:
1. Every container command after a rebuild MUST use `APP_IMAGE=rta-dev` to reference the newly built image
2. Running tests in a Rails project REQUIRES `RAILS_ENV=test` environment variable
3. Stop any running containers before rebuilding to avoid port conflicts
4. Use `--no-cache` to force layer rebuilds (picks up recent changes)

**Common Violations** (❌ WRONG):
```bash
# ❌ Edit Gemfile then run bundle without rebuild
./script/dockercomposerun -do bundle install   # Uses old cached image!

# ❌ Run tests without RAILS_ENV
APP_IMAGE=rta-dev ./script/dockercomposerun -d ./script/run tests   # Wrong env, wrong db!

# ❌ Run tests with -o flag (excludes database)
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -do ./script/run tests   # Tests fail—no db!

# ❌ Forget APP_IMAGE after rebuild
docker build --no-cache --target devenv -t rta-dev .
./script/dockercomposerun -d   # Uses default image, not rta-dev!
```

**Why This Matters**:
- Docker layer caching is aggressive—previous image layers are reused
- `bundle install` runs in the **container image**, not your local OS
- Volume mounts only bind files TO the image, they don't update the image itself
- A stale image will execute stale code regardless of local file edits
- `-do` flag EXCLUDES the database service; tests NEED database

**When to Rebuild**:
- Any change to Dockerfile
- Any change to Gemfile, Gemfile.lock, package.json, requirements.txt
- Any change to dependency-related config (e.g., .ruby-version)
- Before running tests or bundle commands after dependency changes

**Flag for Code Review**: If a change affects Dockerfile or dependencies, verify the image was rebuilt with `--no-cache` BEFORE any container commands ran.

**Reference**: See docs/DEPENDENCIES.md for what types of changes require rebuilds. See [docs/DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md) for complete Docker compose system design, including how dockercomposerun orchestrates file composition, environment variables, and multi-stage builds. See [docs/AI_ASSISTANCE_SESSION_ANALYSIS.md](AI_ASSISTANCE_SESSION_ANALYSIS.md) Part 1 for analysis of this common mistake.

## 3. UNDERSTAND ARCHITECTURE & TOOLS BEFORE DOCUMENTING THEM ⭐

**When adding guidance on project infrastructure, tools, or multi-stage systems:**

- **Understand the full architecture, not just one component**
  - Don't just read devenv-builder, read deploy-builder too
  - Don't just suggest a change in isolation—verify it fits the whole system
  - Ask: "Why does deploy-builder have this but devenv-builder doesn't?"

- **Verify how similar patterns are already implemented elsewhere**
  - If something exists in production stage, check why
  - Don't duplicate logic unless it's intentionally different
  - Reference actual code examples from the codebase

- **Map explicit boundaries between contexts**
  - Document what applies where
  - Explain the distinction between stages/environments
  - Never assume "this works here, so add it everywhere"

- **Test understanding by explaining the purpose of each stage**
  - Can you explain why devenv-builder needs test gems?
  - Can you explain why deploy-builder excludes them?
  - If not, you don't understand the architecture yet

- **First verify how the tool actually works** (test it, read source code)
  - Understand input/output and side effects (volume mounts, environment variables, etc.)
  - Don't assume tool purpose from name or simple testing
  - Document the actual behavior, not your interpretation
  - Reference official docs and source code, not assumptions

**Example mistake**: Documented `./script/dockercomposerun -do bundle install` as "verification" when it actually **generates Gemfile.lock in the container and writes it to native filesystem via volume mount**—two completely different concepts. See [docs/AI_ASSISTANCE_SESSION_ANALYSIS.md](AI_ASSISTANCE_SESSION_ANALYSIS.md) Part 1 for context.

## 4. EXPLICIT CONSTRAINTS
# Editing Gemfile then immediately running:
./script/dockercomposerun -do bundle install   # ❌ WRONG - uses old cached image!
# Result: Gemfile.lock generated with Rails 7, not Rails 8
```

**Why This Matters**:
- Docker layer caching is aggressive—previous image layers are reused
- `bundle install` runs in the **container image**, not your local OS
- Volume mounts only bind files TO the image, they don't update the image itself
- A stale image will execute stale code regardless of local file edits

**When to Rebuild**:
- Any change to Dockerfile
- Any change to Gemfile, Gemfile.lock, package.json, requirements.txt
- Any change to dependency-related config (e.g., .ruby-version)
- Before running tests or bundle commands after dependency changes

**Flag for Code Review**: If a change affects Dockerfile or dependencies, verify the image was rebuilt with `--no-cache` BEFORE any container commands ran.

**Reference**: See docs/DEPENDENCIES.md for what types of changes require rebuilds. See [docs/DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md) for complete Docker compose system design, including how dockercomposerun orchestrates file composition, environment variables, and multi-stage builds.

**Example mistake I made**: Attempted to run `bundle install` against a stale Rails 7 image instead of rebuilding the image first. This resulted in Gemfile.lock being generated with wrong versions, requiring rerun with correct image.

## 3. UNDERSTAND ARCHITECTURE & TOOLS BEFORE DOCUMENTING THEM ⭐

**When adding guidance on project infrastructure, tools, or multi-stage systems:**

- **Understand the full architecture, not just one component**
  - Don't just read devenv-builder, read deploy-builder too
  - Don't just suggest a change in isolation—verify it fits the whole system

- **Verify how similar patterns are already implemented elsewhere**
  - If something exists in production stage, check why
  - Don't duplicate logic unless it's intentionally different
  - Ask: "Why does deploy-builder have this but devenv-builder doesn't?"

- **Map explicit boundaries between contexts**
  - Document what applies where
  - Explain the distinction between stages/environments
  - Never assume "this works here, so add it everywhere"

- **Test understanding by explaining the purpose of each stage**
  - Can you explain why devenv-builder needs test gems?
  - Can you explain why deploy-builder excludes them?
  - If not, you don't understand the architecture yet

- **First verify how the tool actually works** (test it, read source code)
  - Understand input/output and side effects (volume mounts, environment variables, etc.)
  - Don't assume tool purpose from name or simple testing
  - Document the actual behavior, not your interpretation
  - Reference official docs and source code, not assumptions

**Example mistake I made**: Documented `./script/dockercomposerun -do bundle install` as "verification" when it actually **generates Gemfile.lock in the container and writes it to native filesystem via volume mount**—two different concepts.

## 4. EXPLICIT CONSTRAINTS

- State the exact problem or requirement clearly
- Specify which technologies/versions are in use
- Define success criteria and expected outcomes
- Call out any edge cases or special conditions upfront
- Clarify the scope and boundaries of the request

## 5. EVIDENCE-BASED SUGGESTIONS

- Ground recommendations in code patterns already present in this project
- Reference similar implementations in the codebase
- Cite documentation or standards when applicable
- Explain the "why" behind suggestions, not just "what"
- Avoid introducing patterns that don't fit the existing codebase

## 6. CONSISTENCY WITH EXISTING PATTERNS

- Match the style and conventions of the current codebase
- Use existing gems, frameworks, and libraries already in use
- Follow the same error handling, naming, and architecture patterns
- Don't introduce new approaches unless explicitly requested
- Maintain Rails conventions and best practices

## 7. BOUNDED SCOPE

- Focus on the specific file/function/feature mentioned
- Don't over-engineer or add "nice-to-haves"
- Make minimal changes that solve the stated problem
- Avoid scope creep into unrelated areas
- Complete the stated task without unnecessary additions

## 8. TEST-DRIVEN MINDSET

- Suggest changes that are testable
- Include test cases for new functionality
- Verify changes don't break existing tests
- Document expected behavior clearly
- Reference existing test patterns in `/spec` directory

## 9. CONCRETE EXAMPLES

- Show actual code, not pseudo-code
- Use real variable names from the codebase
- Include before/after snippets when applicable
- Reference specific gems/libraries by name and version
- Link to actual file locations in the project

## 10. INPUT VALIDATION & ERROR HANDLING

- Validate all incoming parameters against expected schemas
- Whitelist allowed values for enums and select fields
- Reject unexpected fields early in controllers/middleware
- Define consistent error response formats
- Never expose internal stack traces to clients

## 11. DATABASE QUERY CONSISTENCY

- Use explicit `SELECT` columns instead of `SELECT *`
- Add indexes to frequently queried columns
- Use database constraints (unique, not null, foreign keys)
- Avoid N+1 queries with eager loading (`includes`, `joins`)
- Reference existing database patterns in `/db/schema.rb`

## 12. API CONTRACT STABILITY

- Document expected request/response formats (reference Swagger docs in `/swagger`)
- Return consistent field types (never `"123"` sometimes and `123` other times)
- Include timestamps and pagination metadata consistently
- Version API endpoints (follow existing v1 patterns)
- Maintain backward compatibility

## 13. RAILS STATE MANAGEMENT

- Use transactions for multi-step operations
- Avoid side effects in model callbacks
- Keep business logic in services/operations, not controllers
- Use locks for concurrent access to shared resources
- Follow patterns established in `/app/models` and `/app/controllers`

## 14. DEPENDENCY & CONFIGURATION CHANGES - CONTAINER-BASED LOCK FILE GENERATION ⭐

**Critical Principle**: Gemfile.lock must be generated IN the container runtime environment, not on the native OS. The local filesystem is volume-mounted into the container, so bundle install resolves dependencies against container libraries/versions and writes Gemfile.lock back to your native filesystem.

When making Gemfile changes:

1. **Edit Gemfile** on native filesystem (e.g., Rails version upgrade, new gem)
2. **Generate Gemfile.lock IN the container environment** (required, not optional):
   ```
   docker build --no-cache --target devenv -t rta-dev .
   APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install
   ```
   - Rebuild image first (Step 1 of Section 2b workflow)
   - `-d`: Development environment (uses docker-compose.dev.yml)
   - `-o`: App only (no database service, faster execution)
   - Volume mount: `/Users/brianbayer/lex/repos/random_thoughts_api` → `/app` in container
   - Result: Gemfile.lock written to native filesystem reflects container's dependency resolution

3. **Why this matters**:
   - Ensures Gemfile.lock dependencies match container OS libraries and Ruby 4.0.1
   - Prevents "works locally but fails in container" issues
   - Makes dev and production lock files consistent (same container environment)
   - Guarantees bundle install in production container will use the same resolved versions

4. **Expected success indicators**:
   - Exit code: 0
   - "Bundle complete!" message
   - Gemfile.lock updated on native filesystem (visible after command completes)
   - No unresolved dependency errors

5. **Reference known outcomes** (e.g., Rails 8.0 upgrade):
   - Rails 7.2.2.2 → 8.0.4 (resolved in container, lock file on native filesystem)
   - web-console 4.2.1 added (development-only, container-resolved)
   - 34 Gemfile dependencies → ~122 total gems (container environment)
   - Build cache optimization (BUNDLE_JOBS=4) speeds installation

6. **Document the change**:
   - Commit the updated Gemfile AND Gemfile.lock
   - Both files reflect container's dependency resolution
   - Include container-generated versions in commit message

### How Future AI Assistance Uses This

When requesting Gemfile changes, AI must:
- Recognize this is NOT optional verification—it's required lock file generation
- Understand volume mount binding and its implications
- Know that Gemfile.lock always comes from container, never native OS
- Reference expected container versions, not native Ruby versions
- Include the command to regenerate lock file in the response
- Reference Section 2b for complete image rebuild workflow

## 15. ENVIRONMENT DISTINCTIONS - LOCAL OS VS. CONTAINER VS. PRODUCTION ⭐

**Always distinguish where code/files are used:**

| Location | When to Edit | When Resolved | Generated By |
|----------|--------------|---------------|--------------|
| **Native Filesystem** (macOS) | Development/editing | N/A | Your editor |
| **Container Dev Environment** | Via volume mount | At runtime | Container (Ruby 4.0.1, Debian) |
| **Production** | N/A | At deployment | Container (same env as dev) |

**Application**:
- Edit `Gemfile` on native FS, generate `Gemfile.lock` IN container (Section 14)
- Edit source code on native FS, test IN container (`./script/dockercomposerun`)
- Never use native Ruby/gem versions as source of truth
- Always verify changes in the actual container environment
- Remember: volume mount means native FS and container FS are the same files—changes propagate both directions

**Example**: When upgrading Rails:
- Edit Gemfile on native FS (local editor)
- Rebuild image (Section 2b, Step 2)
- Run bundle install IN container (Section 2b, Step 3)
- Commit both Gemfile and Gemfile.lock (they reflect the container environment)
- Production uses same container, same Gemfile.lock—no surprises

## 16. MULTI-LAYER & MULTI-STAGE ARCHITECTURE - UNDERSTAND PURPOSE FIRST ⭐

When working with systems that have multiple stages/layers (Docker multi-stage builds, different environments, builder patterns), ALWAYS:

1. **Map each stage/layer's PURPOSE explicitly**:
   - Development stage: What is its job? (local dev with all gems for testing/debugging)
   - Production stage: What is its job? (minimal, optimized for deployment)
   - Each has different requirements and constraints

2. **Verify existing patterns IN EACH STAGE before suggesting changes**:
   - Don't assume a pattern should be added everywhere
   - Check if it already exists correctly in a similar stage
   - Example: If deploy-builder already has `BUNDLE_WITHOUT=development:test`, don't add it to devenv-builder—they have different purposes

3. **Never copy configuration between stages without understanding context**:
   - What's correct for production may break development
   - What's an optimization for one stage may be a limitation for another
   - Document WHY each stage has its configuration

4. **Ask yourself before suggesting changes**:
   - What is this stage responsible for?
   - What constraints apply to THIS stage (not others)?
   - Does a similar stage already handle this differently? Why?
   - Would this change break the stage's purpose?

**Example mistake**: Added `BUNDLE_WITHOUT=development:test` to devenv-builder (development stage) because I saw it in deploy-builder (production stage) without understanding that development REQUIRES test gems for the dev environment. See [docs/AI_ASSISTANCE_SESSION_ANALYSIS.md](AI_ASSISTANCE_SESSION_ANALYSIS.md) Part 1.

## 17. DOCKERFILE ARCHITECTURE - VERIFICATION BEFORE CHANGES ⭐

When suggesting Dockerfile changes, verify:

1. **All multi-stage builders are named and have distinct purposes**:
   - Document each FROM...AS stage
   - Understand what each builds and what it's used for
   - Reference: Dockerfile stages are `ruby-base` → `base-builder` → `devenv-builder`/`deploy-builder` → `devenv`/`deploy`

2. **Configuration flows correctly through inheritance**:
   - base-builder → devenv-builder → devenv image
   - base-builder → deploy-builder → deploy image
   - Changes in base-builder affect both paths
   - Changes in devenv/deploy builders should only affect their path

3. **Environment variables (ENV) are scoped correctly**:
   - Ask: Does this ENV apply to THIS stage only or should it inherit?
   - Is this ENV for build-time or runtime?
   - Does it conflict with inherited ENVs?

4. **Look for existing patterns in OTHER stages**:
   - Before suggesting new configuration, check if similar stages have it
   - If deploy-builder has BUNDLE_WITHOUT but devenv-builder doesn't—that's intentional
   - Ask why before changing

## 18. CONDITIONAL LOGIC & ENVIRONMENT-SPECIFIC CONFIGURATION ⭐

When recommending configurations with conditionals (ENV, if statements):

1. **Understand the scope of applicability**:
   - Development only?
   - Production only?
   - Both, but configured differently?
   - Document explicitly which environments use which config

2. **Never apply an optimization to the wrong environment**:
   - "Fast parallel builds" might be good for dev but not needed for prod images
   - "Minimal dependencies" is good for prod but breaks dev testing
   - Check the CURRENT environment's actual requirements

3. **Verify the environment's purpose before suggesting changes**:
   - Devenv: For developer experience, testing, debugging
   - Production: For deployment, performance, security, size
   - Different stages = different optimization targets
   - Rails environment matters: test DB ≠ dev DB ≠ production data

## 19. IMPACT ANALYSIS - Declare What May Break ⭐

Before suggesting ANY change, declare:

**Direct Impact**: What files/behavior changes directly?
**Cascade Impact**: What else depends on this?
**Environment Impact**: Does this affect dev/prod differently?
**Test Impact**: What tests might fail?
**Config Impact**: Do other configs need updating?

Reference docs/DEPENDENCIES.md to map impacts. Example format:

```
Suggesting change to [X]:
- Direct: Modifies [file] behavior in [way]
- Cascades: May require [Y] and [Z] updates
- Env Impact: Dev [effect], prod [effect]
- Tests: [test group] will break without [fix]
- Config: Must update [config file] and docs/[doc file]

All impacts understood and documentable: YES
Proceed with suggestion.
```

Only proceed if ALL impacts are understood and documented.

## 20. EXPLICIT ASSUMPTION LOGGING ⭐

When suggesting changes, DECLARE assumptions:

"I'm suggesting [X] based on these assumptions:
- Assumption A: [state assumption]
  Verified: [yes/no/partial] - [evidence or source]
- Assumption B: [state assumption]
  Verified: [yes/no/partial] - [evidence or source]

If ANY assumption is unverified, escalate for confirmation before proceeding."

**Example - RIGHT**:
```
Suggesting puma.rb change based on:
- Assumption: Production uses multi-worker mode
  Verified: NO - docs/DEVELOPMENT.md says default is 0, must be ENV
- Assumption: PUMA_PRELOAD_APP optimization is beneficial
  Verified: PARTIAL - Rails 8 docs recommend for multi-process, but not documented here

Action: Request user confirmation before proceeding.
```

**Example - WRONG**:
```
Suggesting puma.rb change. Proceed.
(No assumptions documented—hidden errors.)
```

## 21. DEPENDENCY MAPPING - Understand What Breaks When ⭐

Before suggesting ANY change, read docs/DEPENDENCIES.md:

1. Find your change type (Gemfile, Dockerfile, config, env var)
2. Identify ALL cascading impacts from the table
3. Document which impacts apply to THIS specific change
4. Verify you can handle each impact
5. Include impact list in your suggestion

**Example**:
```
Suggesting Gemfile change to add web-console:
Per docs/DEPENDENCIES.md - Gemfile changes:
- REQUIRED: Regenerate Gemfile.lock IN container ✓
  Command: docker build --no-cache --target devenv -t rta-dev .
           APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install
- MAY REQUIRE: Update config/environments/default.rb - NO (web-console has no config)
- MAY REQUIRE: Update docs/DEVELOPMENT.md - NO (doesn't affect workflow)
- Must rebuild image and test after: YES
  Command: APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests

Impacts handled: 1/3 required, others N/A.
Proceed.
```

If an impact applies and you DON'T handle it, escalate instead.

---

## Additional Context & References

**Quick Reference for Common Workflows**:

```bash
# Development environment setup
docker build --no-cache --target devenv -t rta-dev .
APP_IMAGE=rta-dev ./script/dockercomposerun -d

# Run tests (RAILS_ENV=test required, -d flag required for database)
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests

# Run linting (no database needed with -o flag)
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run lint

# Bundle operations (no database needed with -o flag)
APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install

# Dependency security scan (no database needed)
APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run depsecscan
```

**File Reference Guide**:

| Task | Read This | Then Check | Reference Section |
|------|-----------|-----------|-------------------|
| Making Gemfile changes | Section 14 | docs/DEPENDENCIES.md | Section 21 |
| Running tests | OPERATING.md | DEVELOPMENT.md | Section 2b |
| Docker changes | Section 17 | Dockerfile | Section 16 |
| Rails config | config/environments/default.rb | DEVELOPMENT.md | Section 15 |
| Container workflow | Section 2b | docs/DOCKER_SYSTEM_ARCHITECTURE.md | N/A |
| Session analysis | docs/AI_ASSISTANCE_SESSION_ANALYSIS.md | Part 1 (Mistakes) | N/A |

---

**Include this file reference in prompts like:**
```
Follow docs/COPILOT_GUIDES.md
Reference docs/DEPENDENCIES.md for impact analysis
Reference docs/DOCKER_SYSTEM_ARCHITECTURE.md for container framework details
Reference docs/AI_ASSISTANCE_SESSION_ANALYSIS.md for session learnings
```
