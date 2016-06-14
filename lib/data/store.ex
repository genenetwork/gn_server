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

  def datasets do
    {:ok, rows} = DB.query("select InbredSet.inbredsetid,InbredSet.speciesid,InbredSet.name,ProbeFreeze.name from InbredSet,ProbeFreeze where InbredSet.inbredsetid=ProbeFreeze.inbredsetid")
    IO.inspect rows
    nlist = Enum.map(rows, fn(x) -> {inbredset_id,species_id,inbredset_name,full_name} = x ; [inbredset_id,species_id,inbredset_name,full_name] end)
    nlist
  end

  def menu_species do
    {:ok, rows} = DB.query("SELECT speciesid,name,menuname FROM Species")
    # IO.inspect rows
    nlist = Enum.map(rows, fn(x) -> {species_id,species_name,full_name} = x ; [species_id,species_name,full_name] end)
    %{ species: nlist }
  end

end
