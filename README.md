# WIP: random_thoughts_api

> **This is a Work In Progress**

A simple demonstration-only Rails API with OpenAPI (Swagger)
that implements a random thought in JSON format...
```json
{
  "thought": "A random thought",
  "name": "The Thinker's Name"
}
```

The `Dockerfile` for this project only supports the
Development Environment where the source code is volume
mounted into the container.

---

## API Endpoints
This API contains the following endpoints...
* Authentication endpoints...
  * **Login** user: `post /login`
    with Request Body...
    ```json
    {
      "authentication": {
        "email": "string",
        "password": "string"
      }
    }
    ```

  * **Logout** user: `get /logout`
    (e.g. http://localhost:3000/logout)
    > **Requires** Authorization JWT from login
    > in request header

* User endpoints...
  * **Index** all users: `get /users?page={num}`
    (e.g. http://localhost:3000/users?page=2)
    > **Requires** Authorization JWT from login
    > in request header

  * **Show** user {id}: `get /users/{id}`
    (e.g. http://localhost:3000/users/1)
    > **Requires** Authorization JWT from login
    > in request header

  * **Create** user: `post /users`
    with Request Body...
    ```json
    {
      "user": {
        "email": "string",
        "display_name": "string",
        "password": "stringst",
        "password_confirmation": "stringst"
      }
    }
    ```

  * **Update** user {id}: `patch /users/{id}`
    with Request Body...
    ```json
    {
      "user": {
        "email": "string",
        "display_name": "string",
        "password": "stringst",
        "password_confirmation": "stringst"
      }
    }
    ```
    > **Requires** Authorization JWT from login
    > in request header

  * **Delete** user {id}: `delete /users/{id}`
    > **Requires** Authorization JWT from login
    > in request header

* Random Thoughts endpoints...
  * **Index** all random thoughts: `get /random_thoughts?page={num}`
    (e.g. http://localhost:3000/random_thoughts?page=2)

  * **Show** random thought {id}: `get /random_thoughts/{id}`
    (e.g. http://localhost:3000/random_thoughts/1)

  * **Create** random thought: `post /random_thoughts`
    with Request Body...
    ```json
    {
      "random_thought": {
        "thought": "string",
        "name": "string"
      }
    }
    ```
    > **Requires** Authorization JWT from login
    > in request header

  * **Update** random thought {id}: `patch /random_thoughts/{id}`
    with Request Body...
    ```json
    {
      "random_thought": {
        "thought": "string",
        "name": "string"
      }
    }
    ```
    > **Requires** Authorization JWT from login
    > in request header

  * **Delete** random thought {id}: `delete /random_thoughts/{id}`
    > **Requires** Authorization JWT from login
    > in request header

## Development
This project can be developed using the supplied basic,
container-based development environment which includes
`vim`, `git`, `curl`, and `psql`.

The containerized development environment contains this
application along with an orchestrated PostgreSQL container.

The development environment application container volume mounts
your local source code to recognize and persist any changes.

By default the development environment application container
executes the `bash` shell providing a command line interface
into the application container.

### To Develop Using the Container-Based Development Environment
The easiest way to run the containerized development environment
is with the docker-compose framework using the `dockercomposerun`
script.

#### PREREQUISITES
In order to run the containerized development environment...

1. Docker must be installed and running

#### Running the Containerized Development Environment
1. Run the following command to run the containerized development
   environment...
   ```
   ./script/dockercomposerun
   ```

   > This will pull and run the latest development environment
   > image of this project along with the latest `postgres`
   > image.

2. To exit the containerized development environment, run the
   following command ...
   ```
   exit
   ```

#### Building And Running Your Own Development Environment Image
You can also build and run your own development environment
image.  This is helpful when you are updating gems or
changing the `Dockerfile`.

1. Run the following command to build your image...
   ```
   docker build --no-cache -t local-random_thoughts_api-dev .
   ```

2. Run the following command to run the containerized development
   environment using your image...
   ```
   APP_IMAGE=local-random_thoughts_api-dev ./script/dockercomposerun
   ```

### Mappings to Host Machine
The containers in the containerized development environment have
their ports mapped to the host machine (i.e. `localhost`) for
visibility and access.

* A running Rails server in the application container is mapped to
  http://localhost:3000.

* The PostgreSQL container is mapped to `localhost:5432` and can
  be accessed on the host machine with the database connection string
  `postgresql://random_thoughts_api:banana@localhost:5432/random_thoughts_api`
  (e.g. `psql postgresql://random_thoughts_api:banana@localhost:5432/random_thoughts_api`)

---

## Operating

### PREREQUISITES
In order to run the rails commands for this application...

1. You must set the required environment variable `APP_JWT_SECRET`
   > Note that to even generate a secret for setting `APP_JWT_SECRET`
   > using the `rails secret` command, you must have already set
   > `APP_JWT_SECRET` with an initial value.  You can use this
   > hack...
   > ```
   > export APP_JWT_SECRET=chicken-to-lay-first-egg
   > ```

Provided that you have already set `APP_JWT_SECRET` to some initial
value, to generate a suitable secret for setting `APP_JWT_SECRET`,
you can use the `rails secret` command, for example...
```
APP_JWT_SECRET=$(bundle exec bin/rails secret)
```

### Database
This project uses a Rails-supported PostgreSQL database with
the same configuration in all environments.

Use the `DATABASE_URL`environment variable set to a standard
database connection string to specify the database.

It is recommended to use the official
[PostgreSQL Docker image](https://hub.docker.com/_/postgres)
without a persistent volume (data) for the `development`
and `test` environments.

#### Seed Data
There is some sample seed data that creates two users and one
random thought that belongs to the first user.

* First user email: `qhound@thisisfine.com`
* Second user email: `user@example.com`

The password for both users is `password`.

Run the following command to add the seed data...
```
bundle exec bin/rails db:seed
```

### Testing
If you are using the same database for `development` and `test`,
run the following command first to set the database for the
`test` environment...
```
bundle exec bin/rails db:environment:set RAILS_ENV=test
```

Run the following command to run the tests...
```
./script/run tests
```

> :warning: If you are using the same database for `development`
> and `test`, these steps can destroy any data in your
> `development` database.

### Dependency Static Security Scanning
This project includes the
[`bundler-audit`](https://github.com/rubysec/bundler-audit)
gem for statically scanning the gems for any known security
vulnerabilities.

Run the following command to run the dependency security scan...
```
./script/run depsecscan
```

### Running the Application
Run the following command to run the Rails server...
```
./script/run server
```

or to run the server in detached mode...
```
./script/run server -d
```

---

## Swagger

### To Generate the Swagger File

Run the following command to generate the Swagger file for the
application...
```
./script/run swaggerize
```

### Swagger UI

By default the Swagger UI is located at http://localhost:3000/api-docs/


---

## Specifications
### Versions

* Rails: 7.0.4.3
* Ruby: 3.2.1

### Support

* [PostgreSQL](https://www.postgresql.org/) - Database
* [JWT](https://github.com/jwt/ruby-jwt) - Authorization
* [RSpec](http://rspec.info/) - Test Framework
* [Factory Bot](https://github.com/thoughtbot/factory_bot) - Test
  Data Factory Framework
* [rswag](https://github.com/rswag/rswag) - Swagger/OpenAPI
  Tooling
* [bundler-audit](https://github.com/rubysec/bundler-audit) - Dependency
  Static Security
