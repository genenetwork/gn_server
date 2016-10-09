defmodule GnServer.Logic.Token do

  def validate_token(token) do
    if is_nil token do
      {:invalid}
    else
      path = Application.get_env(:gn_server, :upload_dir) |> Path.join(token)
      IO.puts "inspecting token"
      IO.inspect token
      case File.exists? path do
        true -> {:valid, token}
        false -> {:invalid}
      end
    end
  end
end
