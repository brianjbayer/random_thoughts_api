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

:eyes: For more information, see [PREREQUISITES.md](docs/PREREQUISITES.md)

### To Develop Using the Container-Based Development Environment
The easiest way to run the containerized development environment is with
the docker compose framework using the `dockercomposerun` script with the
`-d` (development environment) option...
```
./script/dockercomposerun -d
```

This will pull and run the latest development environment image
of this project along with the latest `postgres` image.

To exit the containerized development environment, run the
following command ...
```
exit
```

### Building And Running Your Own Development Environment Image
You can build and run your own development environment
image.  This is helpful when you are updating gems or
changing the `Dockerfile`.

1. Run the following command to build your image...
   ```
   docker build --no-cache --target devenv -t rta-dev .
   ```

2. Run the following command to run the containerized development
   environment using your image specified with the `APP_IMAGE`
   environment variable...
   ```
   APP_IMAGE=rta-dev ./script/dockercomposerun -d
   ```

### Specifying the Source Code Location
You can use another directory as the source code for the development
environment by setting the `APP_SRC` environment variable.
For example...
```
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
   ```
   docker build --no-cache -t rta .
   ```

2. Run the following command to run the CI environment
   using your image...
   ```
   APP_IMAGE=rta ./script/dockercomposerun -c
   ```

### Running the End-To-End Tests
You can also run the
[random_thoughts_api_e2e](https://github.com/brianjbayer/random_thoughts_api_e2e)
End-to-End (E2E) tests using the `dockercomposerun` script with
the `-t` (E2E tests) option.  This will pull the pinned E2E
tests image and run them against the running application container.

To run the E2E tests against the development environment, run the
following command...
```
RAILS_ENV=development ./script/dockercomposerun -dt
```

To run the E2E tests against your own deployment image, run the
following command...
```
APP_IMAGE=rta ./script/dockercomposerun -ct
```

### Operating
:eyes: For information on operating the application including
running the unit tests, static dependency security scanning,
linting, generating the Swagger specification, and running the
server, see [OPERATING.md](OPERATING.md).
