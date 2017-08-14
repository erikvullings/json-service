defmodule JsonService do
  @moduledoc """
  JSON Service is a simple JSON REST API that stores information
  in memory and maintains a backup on file.
  """

  use Application
  require Logger

  @doc """
  Start the supervisor.

  ## Examples

    $ mix run --no-halt

  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = Application.get_env(:json_service, :port, 8080)
    children = [
      worker(JsonService.Cache, []),
      supervisor(JsonService.Server, []),
      Plug.Adapters.Cowboy.child_spec(:http, JsonService.Router, [], port: port)
    ]

    Logger.info "Started application"

    opts = [strategy: :one_for_one, name: JsonService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
