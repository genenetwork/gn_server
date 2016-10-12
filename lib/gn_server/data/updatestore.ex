defmodule GnServer.Data.UpdateStore do
  def echo(params, body) do
    # IO.inspect [params, body]
    body
  end
  def phenotypes(params) do
    %{"submit" => "ok"}
  end
end
