# This module should only contain the MySQL calls to the backend to
# fetch data. Assembling more complex structures should happen in the
# Assemble modules.
#
# All functions return lists of lists, rather than lists of
# tuples. Main reason is that tuples do not go nicely with JSON.

defmodule GnServer.Data.Store do

  alias GnServer.Backend.MySQL, as: DB

  def species do
    {:ok, rows} = DB.query("SELECT speciesid,name,fullname FROM Species")
    for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )
  end

  def datasets do
    {:ok, rows} = DB.query("select InbredSet.inbredsetid,InbredSet.speciesid,InbredSet.name,ProbeFreeze.name from InbredSet,ProbeFreeze where InbredSet.inbredsetid=ProbeFreeze.inbredsetid")
    for r <- rows, do: ( {inbredset_id,species_id,inbredset_name,full_name} = r ; [inbredset_id,species_id,inbredset_name,full_name] )
  end

  def menu_species do
    {:ok, rows} = DB.query("SELECT speciesid,name,menuname FROM Species")
    for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )
  end

  def menu_groups(species) do
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
    for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )
  end

  def menu_types(species, group) do
    query = """
    select distinct Tissue.Name
    from ProbeFreeze,ProbeSetFreeze,InbredSet,Tissue,Species
    where Species.Name = '#{species}' and Species.Id = InbredSet.SpeciesId and
      InbredSet.Name = '#{group}' and
      ProbeFreeze.TissueId = Tissue.Id and
      ProbeFreeze.InbredSetId = InbredSet.Id and
      ProbeSetFreeze.ProbeFreezeId = ProbeFreeze.Id and
      ProbeSetFreeze.public > 0
      order by Tissue.Name
    """
    {:ok, rows} = DB.query(query)
    for r <- rows, do: ( {tissue} = r; [tissue] )
  end
end
