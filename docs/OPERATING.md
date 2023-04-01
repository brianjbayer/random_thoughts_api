## Operating random_thoughts_api

> :eyes: Please see the [PREREQUISITES.md](docs/PREREQUISITES.md)
> for running and operating this application


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
./script/run rails db:seed
```

### Testing
If you are using the same database for `development` and `test`,
run the following command first to set the database for the
`test` environment...
```
./script/run rails db:environment:set RAILS_ENV=test
```

Run the following command to run the tests...
```
./script/run tests
```

> :warning: If you are using the same database for `development`
> and `test`, these steps can destroy any data in your
> `development` database.

This project is configured so that you can re-run just the
failing tests using the RSpec `--only-failures` (or
`--next-failure`) option.
```
./script/run tests --only-failures
```

### Code Style/Linting
This project includes the Rubocop gems
[`rubocop`](https://github.com/rubocop/rubocop),
[`rubocop-rails`](https://github.com/rubocop/rubocop-rails),
[`rubocop-rspec`](https://github.com/rubocop/rubocop-rspec)
for linting and ensuring a consistent code style.

Run the following command to run code style/linting...
```
./script/run lint
```

### Dependency Static Security Scanning
This project includes the
[`bundler-audit`](https://github.com/rubysec/bundler-audit)
gem for statically scanning the gems for any known security
vulnerabilities.

Run the following command to run the dependency security scan...
```
./script/run depsecscan
```

### Running the Server
Run the following command to run the Rails server...
```
./script/run server
```

or to run the server in detached mode...
```
./script/run server -d
```

## Swagger

### To Generate the Swagger File

Run the following command to generate the Swagger file for the
application...
```
./script/run swaggerize
```
