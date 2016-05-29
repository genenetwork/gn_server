defmodule GnServer.Data.Store do
  
  alias GnServer.Backend.MySQL, as: DB

  def species do
    {:ok, rows} = DB.query("SELECT speciesid,name,fullname FROM Species")
    # IO.inspect rows
    nlist = Enum.map(rows, fn(x) -> {species_id,species_name,full_name} = x ; [species_id,species_name,full_name] end)
    # IO.puts Poison.encode_to_iodata!(nlist)
    # IO.puts Enum.join(nlist,"\n")
    nlist
  end

end
