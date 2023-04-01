## Prerequisites for Running random_thoughts_api

In order to run this application or any of the Rails commands
for it...

1. You must have Docker installed and running on your host
   machine

2. You must set the required Rails environment variable
   `SECRET_KEY_BASE`

3. You must set the required environment variable `APP_JWT_SECRET`

> Note that to even generate a secret for setting
> `SECRET_KEY_BASE` or `APP_JWT_SECRET` using the
> `rails secret` command, you must have already set
> `SECRET_KEY_BASE` and `APP_JWT_SECRET` with an initial
> value.  You can use this hack...
> ```
> export SECRET_KEY_BASE=chicken-to-lay-first-egg
> export APP_JWT_SECRET=chicken-to-lay-first-egg
> ```

Provided that you have already set `SECRET_KEY_BASE`
and `APP_JWT_SECRET` to some initial values, to generate
a suitable secret, you can use the `rails secret` command,
for example...
```
SECRET_KEY_BASE=$(bundle exec bin/rails secret) APP_JWT_SECRET=$(bundle exec bin/rails secret)
```
