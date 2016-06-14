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
    nlist
  end

  def menu_groups do
    # for species_name, _species_full_name in species:
    nlist = Enum.map(menu_species, fn(x) -> [_,species,_]=x ;
      query = """
    select InbredSet.id,InbredSet.Name,InbredSet.FullName
    from InbredSet,Species,ProbeFreeze,GenoFreeze,PublishFreeze
    where Species.Name = '#{species}'
      and InbredSet.SpeciesId = Species.Id and InbredSet.Name != 'BXD300'
      and
                       (PublishFreeze.InbredSetId = InbredSet.Id
                        or GenoFreeze.InbredSetId = InbredSet.Id
                        or ProbeFreeze.InbredSetId = InbredSet.Id)
                        group by InbredSet.Name
                        order by InbredSet.Name
"""
      {:ok, rows} = DB.query(query)
      IO.inspect rows
      [ species, Enum.map(rows, fn(x) -> {id,name,fullname} = x ; [id,name,fullname] end) ]

    end
    );
    for [k,v] <- nlist, into: %{}, do: { k, v }
  end

  def menu_main do
    %{ species: menu_species,
       groups: menu_groups}
  end
end
