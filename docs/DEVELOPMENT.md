## Development of random_thoughts_api

This project can be developed using the supplied
container-based development environment which includes
`vim`, `git`, `curl`, and `psql`.

The containerized development environment contains this
application along with an orchestrated PostgreSQL container.

The development environment application container volume mounts
your local source code to recognize and persist any changes.

By default the development environment application container
executes the `bash` shell providing a command line interface
into the application container.

### Prerequisites

In order to run this application or any of the Rails commands
for it...

1. You must have Docker installed and running on your host
   machine

2. You must set the required Rails environment variable
   `SECRET_KEY_BASE`

3. You must set the required environment variable `APP_JWT_SECRET`

:eyes: For more information, see [PREREQUISITES.md](PREREQUISITES.md)

### AI-Assisted Development

This project uses AI assistance tools (like GitHub Copilot) to improve code quality and development velocity. To ensure high-quality, reliable outputs from AI assistants:

#### Guidelines for AI Prompts

When requesting AI assistance on this project, always include:

```text
Follow the AI Guidelines section in docs/COPILOT_GUIDES.md
```

This reference ensures the AI assistant adheres to non-hallucination principles including:

- Verification of existing code patterns before suggesting changes
- Evidence-based recommendations grounded in the actual codebase
- Consistency with project conventions and architecture
- Explicit consideration of the Rails framework and existing gems
- Test-driven approach matching `/spec` patterns

#### Best Practices

- Reference specific file locations and line numbers in your requests
- Be explicit about the scope and expected outcome
- Ask for verification before making changes
- Review generated code against the existing codebase patterns
- Reference the `docs/COPILOT_GUIDES.md` file for complete guidelines

#### Dependency & Configuration Changes

**Important**: Gemfile.lock is always generated IN the container environment using the volume-mounted source code. When you update Gemfile, you must regenerate Gemfile.lock in the container (it's required, not optional):

```bash
./script/dockercomposerun -do bundle install
```

This command:
- Resolves dependencies using container Ruby 4.0.1 and system libraries
- Writes Gemfile.lock to your native filesystem via volume mount
- Ensures dev and production have identical dependency resolution

See section 13 (Dependency & Configuration Changes - Container-Based Lock File Generation) in `docs/COPILOT_GUIDES.md` for full details.

#### Rails 8 Specific Notes

- **Gemfile**: Rails 8.0.4 with web-console for development error pages
- **Ruby Version**: 4.0.1 (container environment)
- **Puma Configuration**: Supports multi-process workers via `PUMA_WORKERS` environment variable
  - Development: `PUMA_WORKERS=0` (threads-only, default)
  - Production: Set `PUMA_WORKERS` to CPU count or desired worker count
  - Preload app with `PUMA_PRELOAD_APP=true` for multi-process mode
- **Environment Variables (12-factor)**:
  - Required: `SECRET_KEY_BASE`, `APP_JWT_SECRET`
  - Optional: `RAILS_ASSUME_SSL`, `RAILS_FORCE_SSL`, `RAILS_LOG_TO_STDOUT`, `RAILS_LOG_LEVEL`
  - Database: `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `PGPORT`
  - Puma: `PORT`, `RAILS_MAX_THREADS`, `PUMA_WORKERS`, `PUMA_PRELOAD_APP`
- **Gemfile.lock**: Always regenerated in container environment via `./script/dockercomposerun -do bundle install`

### To Develop Using the Container-Based Development Environment

The easiest way to run the containerized development environment is with
the docker compose framework using the `dockercomposerun` script with the
`-d` (development environment) option...

```bash
./script/dockercomposerun -d
```

This will pull and run the latest development environment image
of this project along with the latest `postgres` image.

> :fast_forward: The docker compose framework provides default
> values for `SECRET_KEY_BASE` and `APP_JWT_SECRET` for you

To exit the containerized development environment, run the
following command ...

```bash
exit
```

### Building And Running Your Own Development Environment Image

You can build and run your own development environment
image.  This is helpful when you are updating gems or
changing the `Dockerfile`.

**Important**: After updating Gemfile, Dockerfile, or dependencies, you MUST rebuild the image before running any container commands. The old cached image will not pick up your changes.

1. Run the following command to build your image...

   ```bash
   docker build --no-cache --target devenv -t rta-dev .
   ```

2. Use the `APP_IMAGE` environment variable when running subsequent container commands:

   ```bash
   # For interactive development shell:
   APP_IMAGE=rta-dev ./script/dockercomposerun -d

   # For running tests (RAILS_ENV=test required, -d flag required for database):
   APP_IMAGE=rta-dev RAILS_ENV=test ./script/dockercomposerun -d ./script/run tests

   # For bundle install after Gemfile changes (no database needed):
   APP_IMAGE=rta-dev ./script/dockercomposerun -do bundle install

   # For running linting/security (no database needed):
   APP_IMAGE=rta-dev ./script/dockercomposerun -do ./script/run lint
   ```

**Critical**:
- Always use `APP_IMAGE=rta-dev` for all container commands after rebuilding
- Always use `RAILS_ENV=test` when running tests (this is a Rails project requirement)

### Specifying the Source Code Location

You can use another directory as the source code for the development
environment by setting the `APP_SRC` environment variable.
For example...

```bash
APP_SRC=${PWD} APP_IMAGE=rta-dev ./script/dockercomposerun -d
```

### Building And Running Your Own Deployment (Production) Image

You can also build and run your own deployment (i.e. Production)
environment image.  The deployment image is self-contained and
immutable, containing the application source code.  By default
the deployment image runs the application server.

To run your own deployment image using the docker compose
framework, use the `dockercomposerun` script with the `-c`
(CI environment) option and specify your image name with the
`APP_SRC` environment variable.

1. Run the following command to build your deployment image...

   ```bash
   docker build --no-cache -t rta .
   ```

2. Run the following command to run the CI environment
   using your image...

   ```bash
   APP_IMAGE=rta ./script/dockercomposerun -c
   ```

### Running the Perf Tests

You can also run the Perf(ormance) tests using the `dockercomposerun`
script with the `-p` (Perf tests) option.  This will pull the
[grafana/k6](https://k6.io/) load test tool image and run the
specified test script against the running application container.

The grafana/k6 container runs the k6 application as its entrypoint,
so it expects a k6 command e.g. `new`, `run user_create_stress_test.js`.

To specify the tests script directory, use the `PERF_SRC` environment
variable (e.g. `PERF_SRC=./k6`)

For example, to run the load test script `user_create_stress_test.js`
located in your `k6` subdirectory, run the following command...

```bash
PERF_SRC=./k6 ./script/dockercomposerun -p "run" "user_create_stress_test.js"
```

### Operating

:eyes: For information on operating the application including
running the unit tests, static dependency security scanning,
linting, generating the Swagger specification, and running the
server, see [OPERATING.md](OPERATING.md).

For a complete understanding of the Docker Compose system architecture, including multi-stage builds, file composition, and environment variable configuration, see [DOCKER_SYSTEM_ARCHITECTURE.md](DOCKER_SYSTEM_ARCHITECTURE.md).
