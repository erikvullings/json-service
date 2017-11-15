defmodule JsonService.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias JsonService.Server
  alias JsonService.Intervention
  # alias JsonService.Plug.VerifyRequest

  import JsonService.Plug.StatusCodes, only: [status_code: 1]

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :json_service
  end

  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json],
    pass:  ["text/*", "application/*"], json_decoder: Poison
  # plug VerifyRequest, fields: ["content", "mimetype"], paths:  ["/upload"]

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/", do: send_resp(conn, status_code(:ok), "Welcome, stranger")

  get "/api/v1/interventions/:userid" do
    # IO.puts "User ID: #{userid}'s items:'"
    userList = Server.find_list userid
    items = if userList == nil, do: "", else: JsonService.List.items userList
    # IO.puts inspect items
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code(:ok), Poison.encode! items)
  end

  post "/api/v1/interventions/:userid" do
    # IO.puts "User ID: #{userid} is posting"
    msg = conn.body_params
    # IO.inspect msg # Prints JSON POST body
    userList = Server.find_or_create_list userid
    # IO.inspect userList
    intervention = if Map.has_key?(msg, "id") do
      Intervention.new(msg["id"], msg["from"], msg["to"], msg["type"], msg["subtype"], msg["comment"] || "")
    else
      Intervention.new(msg["from"], msg["to"], msg["type"], msg["subtype"], msg["comment"] || "")
    end
    JsonService.List.add userList, intervention
    send_resp(conn, status_code(:created), Poison.encode! intervention)
  end

  @doc """
  Gets all users and converts their entries to JSON.
  """
  get "/api/v1/interventions" do
    userLists = Enum.map(Server.lists, fn(userList) ->
      items = if userList == nil, do: "", else: JsonService.List.items userList
      IO.inspect items
    end)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code(:ok), Poison.encode! userLists)
  end

  get "/api/v1/interventions/:userid/:id" do
    # IO.puts "User ID: #{userid}, getting item with id: #{id}"
    userList = Server.find_list userid
    item = JsonService.List.item userList, id
    # IO.inspect item
    case item do
      nil -> send_resp(conn, status_code(:not_found), "")
      _ -> send_resp(conn, status_code(:ok), Poison.encode! item)
    end
  end

  put "/api/v1/interventions/:userid/:id" do
    # IO.puts "User ID: #{userid} is updating"
    msg = conn.body_params
    # IO.inspect msg
    userList = Server.find_list userid
    JsonService.List.update userList, Intervention.new(id, msg["from"], msg["to"], msg["type"], msg["subtype"], msg["comment"] || "")
    send_resp(conn, status_code(:accepted), "")
  end

  delete "/api/v1/interventions/:userid/:id" do
    userList = Server.find_list userid
    JsonService.List.delete userList, id
    send_resp(conn, status_code(:ok), "")
  end

  # post "/upload", do: send_resp(conn, status_code(:created), "Uploaded\n")

  match _, do: send_resp(conn, status_code(:not_found), "Oops!")

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end

