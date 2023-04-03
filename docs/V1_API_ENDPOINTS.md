## random_thoughts_api  Version 1 API Endpoints

Version 1 of this API contains the following endpoints...

### Authentication Endpoints
  * **Login** user: `post /v1/login`
    with Request Body...
    ```json
    {
      "authentication": {
        "email": "string",
        "password": "string"
      }
    }
    ```

  * **Logout** user: `delete /v1/login`
    > **Requires** Authorization JWT from login
    > in request header

### User Endpoints
  * **Index** all users: `get /v1/users?page={num}`
    (e.g. http://localhost:3000/v1/users?page=2)
    > **Requires** Authorization JWT from login
    > in request header

    > The `page={num}` query parameter is optional

  * **Show** user {id}: `get /v1/users/{id}`
    (e.g. http://localhost:3000/v1/users/1)
    > **Requires** Authorization JWT from login
    > in request header

  * **Create** user: `post /v1/users`
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

  * **Update** user {id}: `patch /v1/users/{id}`
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

  * **Delete** user {id}: `delete /v1/users/{id}`
    > **Requires** Authorization JWT from login
    > in request header

### RandomThoughts Endpoints
  * **Index** all random thoughts or all random thoughts
    for a user (display_name):
    `get /v1/random_thoughts?page={num}&name={display_name}`
    (e.g. http://localhost:3000/v1/random_thoughts?name=Question%20Hound)
    > The `page={num}` and `name={display_name}` query
    > parameters are optional

  * **Show** random thought {id}: `get /v1/random_thoughts/{id}`
    (e.g. http://localhost:3000/v1/random_thoughts/1)

  * **Create** random thought: `post /v1/random_thoughts`
    with Request Body...
    ```json
    {
      "random_thought": {
        "thought": "string",
        "mood": "string"
      }
    }
    ```
    > **Requires** Authorization JWT from login
    > in request header

  * **Update** random thought {id}: `patch /v1/random_thoughts/{id}`
    with Request Body...
    ```json
    {
      "random_thought": {
        "thought": "string",
        "mood": "string"
      }
    }
    ```
    > **Requires** Authorization JWT from login
    > in request header

  * **Delete** random thought {id}: `delete /v1/random_thoughts/{id}`
    > **Requires** Authorization JWT from login
    > in request header


### For More Information

:eyes: For a complete specification of the API, see the
[Swagger File](https://github.com/brianjbayer/random_thoughts_api/blob/main/swagger/v1/swagger.yaml)
for this version
