# Documentation Index & Navigation Guide

This is your entry point for understanding this project's documentation and how all pieces fit together.

---

## Quick Start

**Never worked on this project before?**

1. Read [README.md](README.md) (5 min) - Understand what this project does
2. Follow [DEVELOPMENT.md](DEVELOPMENT.md) (15 min) - Set up your environment
3. Run tests to verify setup: `APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests`
4. Done! Start developing

**Stuck on something?** Jump to the "Common Issues" section below or read [QUICK_REFERENCE_AND_TROUBLESHOOTING.md](QUICK_REFERENCE_AND_TROUBLESHOOTING.md).

---

## All Documentation Files

### Essential (Read First)

| File | Purpose | Read Time | For |
|------|---------|-----------|-----|
| [README.md](README.md) | Project overview | 5 min | Everyone |
| [PREREQUISITES.md](PREREQUISITES.md) | System setup requirements | 5 min | New developers |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Local development guide | 15 min | Developers |

### Operational (Read Second)

| File | Purpose | Read Time | For |
|------|---------|-----------|-----|
| [OPERATING.md](OPERATING.md) | Running commands | 10 min | Developers & Ops |
| [QUICK_REFERENCE_AND_TROUBLESHOOTING.md](QUICK_REFERENCE_AND_TROUBLESHOOTING.md) | Quick commands & fixes | On-demand | Developers |

### Advanced (Read When Needed)

| File | Purpose | Read Time | For |
|------|---------|-----------|-----|
| [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md) | Container/compose design | 20 min | Architects & Debuggers |
| [DEPENDENCIES.md](DEPENDENCIES.md) | Change impact analysis | On-demand | Reviewers |
| [APPLICATION_DATA_MODEL.md](APPLICATION_DATA_MODEL.md) | Database schema & model relationships | 10 min | Developers & Analysts |
| [V1_API_ENDPOINTS.md](V1_API_ENDPOINTS.md) | API documentation | On-demand | API Users |

### AI Assistance (Include in AI Prompts)

| File | Purpose | For |
|------|---------|-----|
| [COPILOT_GUIDES.md](COPILOT_GUIDES.md) | AI-assistance guidelines | Developers using AI |
| [AI_ASSISTANCE_SESSION_ANALYSIS.md](AI_ASSISTANCE_SESSION_ANALYSIS.md) | Session learnings & patterns | Advanced AI usage |
| [DOCUMENTATION_CONSOLIDATION_SUMMARY.md](DOCUMENTATION_CONSOLIDATION_SUMMARY.md) | How all docs fit together | Understanding architecture |

---

## By Scenario

### I'm a new developer

**Read in this order:**
1. README.md
2. PREREQUISITES.md
3. DEVELOPMENT.md
4. QUICK_REFERENCE_AND_TROUBLESHOOTING.md (bookmark this)

**Then:**
- Start with an existing issue or feature request
- Reference commands from DEVELOPMENT.md
- If tests fail, check QUICK_REFERENCE_AND_TROUBLESHOOTING.md

### I need to run tests

**Read**: [DEVELOPMENT.md](DEVELOPMENT.md#running-tests) or [OPERATING.md](OPERATING.md#running-tests)

**Quick command:**
```bash
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests
```

**Troubleshooting:** [QUICK_REFERENCE_AND_TROUBLESHOOTING.md](QUICK_REFERENCE_AND_TROUBLESHOOTING.md#tests-fail-unknown-database)

### I need to understand the container architecture

**Read in this order:**
1. [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md) - Why it's designed this way
2. Look at actual files: Dockerfile, docker-compose.*.yml
3. Read script: script/dockercomposerun

**Key concepts:**
- Multi-stage builds (devenv vs deploy)
- Orthogonal flag composition (-d, -c, -o, -p)
- Volume mount binding (local files ↔ container)
- Environment-based database isolation

### I need to make changes using AI (GitHub Copilot)

**Include in your prompt:**
```
Follow docs/COPILOT_GUIDES.md
Reference docs/DEPENDENCIES.md for impact analysis
Reference docs/DOCKER_SYSTEM_ARCHITECTURE.md for container details
```

**Or for comprehensive context:**
```
Follow docs/COPILOT_GUIDES.md
Reference docs/AI_ASSISTANCE_SESSION_ANALYSIS.md for session context
```

**Read first:**
- [COPILOT_GUIDES.md](COPILOT_GUIDES.md) - Pre-suggestion verification checklist (top section)
- [AI_ASSISTANCE_SESSION_ANALYSIS.md](AI_ASSISTANCE_SESSION_ANALYSIS.md) Part 5 - AI practices

### I'm reviewing a code change

**Check:**
1. Does change affect dependencies? → See [DEPENDENCIES.md](DEPENDENCIES.md)
2. Does it use container commands? → Verify against [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md)
3. Was image rebuilt if needed? → Check [COPILOT_GUIDES.md](COPILOT_GUIDES.md) Section 2b
4. Do tests pass? → [DEVELOPMENT.md](DEVELOPMENT.md#running-tests)

### I'm debugging a failing test

**Steps:**
1. Check what test is failing in the output
2. Try running just that test: `APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests spec/path/to/test_spec.rb`
3. Check [QUICK_REFERENCE_AND_TROUBLESHOOTING.md](QUICK_REFERENCE_AND_TROUBLESHOOTING.md#troubleshooting)
4. Read the spec files: `/spec` directory
5. Add debugging (binding.pry) and re-run

### I'm deploying to production

**Read:**
1. [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md#production-images) - Production image design
2. [OPERATING.md](OPERATING.md#production) - Production instructions
3. GitHub workflows: `.github/workflows/`

**Build production image:**
```bash
docker build --no-cache -t your-registry/rta:latest .
```

**Push and deploy:**
- Follow your deployment system (GitHub Actions, manual, etc.)
- Ensure `SECRET_KEY_BASE` and `APP_JWT_SECRET` are set
- Verify database connection

---

## Common Scenarios → Documentation

| Scenario | Read This | Then This |
|----------|-----------|-----------|
| "How do I run tests?" | OPERATING.md or DEVELOPMENT.md | QUICK_REFERENCE_AND_TROUBLESHOOTING.md if it fails |
| "Tests fail: 'Unknown database'" | QUICK_REFERENCE_AND_TROUBLESHOOTING.md | Likely need `-d` flag, not `-do` |
| "Bundle install fails" | QUICK_REFERENCE_AND_TROUBLESHOOTING.md | Likely need `docker build --no-cache` first |
| "What does the `-o` flag do?" | DOCKER_SYSTEM_ARCHITECTURE.md | QUICK_REFERENCE_AND_TROUBLESHOOTING.md "Flag Guide" |
| "Can I use AI to help?" | COPILOT_GUIDES.md | Include it in your prompt! |
| "What breaks if I change X?" | DEPENDENCIES.md | COPILOT_GUIDES.md section 21 |
| "How do I debug the container?" | DOCKER_SYSTEM_ARCHITECTURE.md | QUICK_REFERENCE_AND_TROUBLESHOOTING.md |
| "What's the database schema?" | APPLICATION_DATA_MODEL.md | Read models in `/app/models/` |
| "What API endpoints exist?" | V1_API_ENDPOINTS.md | Or check `/swagger/v1/` |
| "Why is it designed this way?" | DOCKER_SYSTEM_ARCHITECTURE.md | AI_ASSISTANCE_SESSION_ANALYSIS.md |

---

## Documentation Map (Visual)

```
ENTRY POINTS (Everyone)
├── README.md
└── PREREQUISITES.md

WORKFLOWS (Daily Use)
├── DEVELOPMENT.md
├── OPERATING.md
└── QUICK_REFERENCE_AND_TROUBLESHOOTING.md

ADVANCED (Debugging & Design)
├── DOCKER_SYSTEM_ARCHITECTURE.md
├── DEPENDENCIES.md
├── APPLICATION_DATA_MODEL.md
└── V1_API_ENDPOINTS.md

AI ASSISTANCE (Developers)
├── COPILOT_GUIDES.md
├── AI_ASSISTANCE_SESSION_ANALYSIS.md
└── DOCUMENTATION_CONSOLIDATION_SUMMARY.md

PROJECT FILES
├── Dockerfile (multi-stage)
├── docker-compose.*.yml (composable)
├── script/dockercomposerun (orchestration)
├── script/run (command wrapper)
├── config/environments/ (environment config)
├── app/ (Rails code)
└── spec/ (tests)
```

---

## Key Files to Understand

### Container Setup
- **Dockerfile** - Multi-stage: ruby-base → base-builder → {devenv,deploy}-builder → {devenv,deploy}
- **docker-compose.yml** - Base service definition
- **docker-compose.db.yml** - PostgreSQL service
- **docker-compose.dev.yml** - Development overrides (volumes, defaults)
- **docker-compose.ci.yml** - CI overrides (image selection)

### Orchestration
- **script/dockercomposerun** - Composes files based on flags (-d, -c, -o, -p)
- **script/run** - Wraps common commands (tests, lint, etc.)
- **entrypoint.sh** - Production container startup

### Configuration
- **config/environments/default.rb** - 12-factor centralized config
- **config/database.yml** - Environment-variable-driven DB config
- **config/puma.rb** - Web server config
- **.github/workflows/** - CI/CD pipelines (shows correct flag usage)

### Tests & Linting
- **spec/** - Test suites (models, requests, controllers)
- **config/brakeman.ignore** - Security scan config
- **.rubocop.yml** - Style guide

---

## Making Your First Change

### Example: Add a gem to Gemfile

**WRONG WAY:**
```bash
# Edit Gemfile (add: gem 'new_gem')
./script/dockercomposerun -do bundle install  # ❌ Against stale image!
```

**RIGHT WAY (from COPILOT_GUIDES.md Section 2b):**
```bash
# Step 1: Edit Gemfile (local editor)
# Add: gem 'new_gem', '~> 1.0'

# Step 2: Rebuild image FIRST
docker build --no-cache --target devenv -t rta-dev .

# Step 3: NOW run bundle install in rebuilt image
APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install

# Step 4: Test that tests still pass
APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests

# Step 5: Commit both files (Gemfile + Gemfile.lock)
git add Gemfile Gemfile.lock
git commit -m "Add new_gem for X"
```

**Why?** Gemfile.lock must be generated in the container environment (Ruby 4.0.1), not on macOS. See [COPILOT_GUIDES.md](COPILOT_GUIDES.md) Section 14 for details.

---

## Quick Links by Role

### Developer
- Start: [DEVELOPMENT.md](DEVELOPMENT.md)
- Commands: [QUICK_REFERENCE_AND_TROUBLESHOOTING.md](QUICK_REFERENCE_AND_TROUBLESHOOTING.md)
- Debugging: [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md)
- AI Help: [COPILOT_GUIDES.md](COPILOT_GUIDES.md)

### Code Reviewer
- Changes: [DEPENDENCIES.md](DEPENDENCIES.md)
- Tests: [OPERATING.md](OPERATING.md)
- Docker: [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md)
- AI Generated: [COPILOT_GUIDES.md](COPILOT_GUIDES.md) Section 18-21

### DevOps / Infrastructure
- Container Design: [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md)
- Production: [OPERATING.md](OPERATING.md)
- CI/CD: [.github/workflows/](.github/workflows/)
- Database: [APPLICATION_DATA_MODEL.md](APPLICATION_DATA_MODEL.md)

### Project Maintainer
- Everything: Skim each section above
- AI Quality: [COPILOT_GUIDES.md](COPILOT_GUIDES.md) + [AI_ASSISTANCE_SESSION_ANALYSIS.md](AI_ASSISTANCE_SESSION_ANALYSIS.md)
- Architecture: [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md) + [DOCUMENTATION_CONSOLIDATION_SUMMARY.md](DOCUMENTATION_CONSOLIDATION_SUMMARY.md)

---

## When Documentation is Out of Date

If you find documentation that doesn't match reality:

1. **Check the code first** - Is the code right and docs wrong? Or vice versa?
2. **Update both** - Fix docs AND code if needed
3. **Add context** - Include the "why" in commit message
4. **Test it** - Verify the change works end-to-end
5. **Reference docs** - Link related documentation updates in commit

Example:
```
Commit: Update test command in DEVELOPMENT.md

- Changed: -do flag to -d for tests (database needed)
- Why: Tests require database; -o excludes it
- Verified: Tests pass with new command
- Related: COPILOT_GUIDES.md section 2b, Quick ref section 2

Fixes: Any issues from incorrect test documentation
```

---

## Documentation Updates in This Session

**New Files Created:**
- AI_ASSISTANCE_SESSION_ANALYSIS.md
- DOCUMENTATION_CONSOLIDATION_SUMMARY.md (this file!)
- QUICK_REFERENCE_AND_TROUBLESHOOTING.md

**Major Updates:**
- COPILOT_GUIDES.md - Fixed sections, added checklist, corrected examples
- DEVELOPMENT.md - Fixed test command, updated examples

**Why These Changes:**
See [DOCUMENTATION_CONSOLIDATION_SUMMARY.md](DOCUMENTATION_CONSOLIDATION_SUMMARY.md) for complete analysis of what changed and why.

---

## Getting Help

### "I'm stuck on a command"
→ [QUICK_REFERENCE_AND_TROUBLESHOOTING.md](QUICK_REFERENCE_AND_TROUBLESHOOTING.md)

### "Something isn't working"
→ [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md) (debug sections)

### "I want to use AI assistance"
→ [COPILOT_GUIDES.md](COPILOT_GUIDES.md) (include in prompt)

### "I'm wondering why something is designed this way"
→ [AI_ASSISTANCE_SESSION_ANALYSIS.md](AI_ASSISTANCE_SESSION_ANALYSIS.md) (Part 2 & 3)

### "I need to understand everything"
→ Start at [README.md](README.md), then read this file in order

---

## Pro Tips

1. **Bookmark QUICK_REFERENCE_AND_TROUBLESHOOTING.md** - You'll use it daily
2. **Include COPILOT_GUIDES.md in AI prompts** - For better assistance
3. **Check DEPENDENCIES.md before making changes** - Know what breaks
4. **Run tests before committing** - Always: `APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests`
5. **Read DOCKER_SYSTEM_ARCHITECTURE.md once fully** - Understand the "why" behind everything

---

**Last Updated**: Rails 8 Upgrade Session
**Related Files**: [DOCUMENTATION_CONSOLIDATION_SUMMARY.md](DOCUMENTATION_CONSOLIDATION_SUMMARY.md)
