defmodule GnServer.Data.UpdateStore do
  def echo(params, body) do
    %{"command" => "echo", "params" => params , "body" => body }
  end
  def phenotypes(params) do
    %{"submit" => "ok"}
  end
end
