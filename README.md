# JsonService

A simple Elixir-based JSON REST service, using Plug and Cowboy under the hood.

Most REST services use Phoenix, but a default Phoenix installation generates a lot of superfluous files (controllers, views, etc.) that I didn't need for a simple REST service. Therefore, I've leverages the underlying Plug service to create a simple REST service.

## Installation

In order to install it, assuming you have a working version of Erlang and Elixir installed,
run, first get all dependencies:
```c
$ mix deps.get
```

Next, run the service:
```c
$ mix run --no-halt
```
Note that all results are persisted in the file "interventions.tab" (a backup is created every minute).

## Configuration
In `config/config.exs` you can specify the PORT to use (default 8080).

## Usage

You can access the REST interface by POST-ing a JSON message to:
http://localhost:8080/api/v1/interventions/USERID
It is assumed that each intervention has the following format:
```json
{
  "from": 12345,
  "to": 23456,
  "type": "my type",
  "comment": "new comment"
}
```

So the base_url = http://localhost:8080/api/v1/interventions/

And the API supports the following end-points:

- GET base_url/USERID: Get all interventions for user USERID
- POST base_url/USERID: Create a new intervention for user USERID
- GET base_url/USERID/ID: Get intervention with id == ID
- PUT base_url/USERID/ID: Update intervention with id == ID
- DELETE base_url/USERID/ID: Delete intervention with id == ID
