# This module should only contain the MySQL calls to the backend to
# fetch data. Assembling more complex structures should happen in the
# Assemble modules.
#
# All functions return lists of lists, rather than lists of
# tuples. Main reason is that tuples do not go nicely with JSON.

defmodule GnServer.Data.Store do

  alias GnServer.Backend.MySQL, as: DB

  defp use_type(id) do
    try do
      { :integer, String.to_integer(id) }
    rescue
      _ in ArgumentError -> { :string, id }
    end
  end

  def species do
    {:ok, rows} = DB.query("SELECT speciesid,name,fullname FROM Species")
    for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )
  end

  def datasets(group) do
    query = """
SELECT DISTINCT D.Id,D.Name,D.FullName
FROM ProbeSetFreeze AS D, ProbeFreeze as D2, InbredSet, Tissue, Species
WHERE
    InbredSet.Name = '#{group}' and
    D.ProbeFreezeId = D2.Id
    AND D2.TissueId = Tissue.Id
    AND D2.InbredSetId = InbredSet.Id
    AND D.confidentiality < 1
    AND D.public > 0
"""
    {:ok, rows} = DB.query(query)
    for r <- rows, do: ( {id,name,full_name} = r ; [id,name,full_name] )
  end

  def groups(species) do
    subq =
      case use_type(species) do
        { :integer, i } -> "Species.id = #{i}"
        { :string, s }  -> "Species.Name = '#{s}'"
      end

    query = """
SELECT distinct InbredSet.id,InbredSet.Name,InbredSet.FullName
FROM InbredSet,Species,ProbeFreeze,GenoFreeze,PublishFreeze
WHERE #{subq}
and InbredSet.SpeciesId = Species.Id and InbredSet.Name != 'BXD300'
and (PublishFreeze.InbredSetId = InbredSet.Id
     or GenoFreeze.InbredSetId = InbredSet.Id
     or ProbeFreeze.InbredSetId = InbredSet.Id)
"""
    {:ok, rows} = DB.query(query)
    for r <- rows, do: ( {id,name,full_name} = r ; [id,name,full_name] )
  end

  def group_info(group) do
    subq =
      case use_type(group) do
        { :integer, i } -> "C.id = #{i}"
        { :string, s }  -> "C.Name = '#{s}'"
      end
    query = "
SELECT DISTINCT Species.speciesid,Species.Name,C.InbredSetid,C.name,C.mappingmethodid,C.genetictype
FROM Species, InbredSet as C
WHERE #{subq} and C.SpeciesId = Species.Id"
    {:ok, rows} = DB.query(query)
    for r <- rows, do: ( {species_id,species,group_id,group_name,method_id,genetic_type} = r; [group_id,group_name,species_id,species,method_id,genetic_type] )
  end

  def chr_info(dataset_name) do
    subq =
      case use_type(dataset_name) do
        { :integer, i } -> "C.id = #{i}"
        { :string, s }  -> "C.Name = '#{s}'"
      end

      query = """
SELECT Chr_Length.Name, Length
FROM Chr_Length, InbredSet as C
WHERE #{subq}
AND Chr_Length.SpeciesId = C.SpeciesId
ORDER BY Chr_Length.OrderId
      """
    {:ok, rows} = DB.query(query)
    for r <- rows, do: ( {chr_name,chr_len} = r; [chr_name,chr_len] )
  end

  def dataset_info(dataset_name) do
    subq =
      case use_type(dataset_name) do
        { :integer, i } -> "D.id = #{i}"
        { :string, s }  -> "D.Name = '#{s}'"
      end

    query = """
SELECT D.Id, D.Name, D.FullName, D.ShortName, D.DataScale, D2.TissueId, Tissue.Name, D.public, D.confidentiality
FROM ProbeSetFreeze as D, ProbeFreeze as D2, Tissue
WHERE #{subq}
    AND D.public > 0
    AND D.ProbeFreezeId = D2.Id
    AND D2.TissueId = Tissue.Id
    """
    {:ok, rows} = DB.query(query)
    for r <- rows, do: ( {id,name,full_name,short_name,data_scale,tissue_id,tissue_name,public,confidential} = r; [id,name,full_name,short_name,data_scale,tissue_id,tissue_name,public,confidential] )
  end


  def menu_species do
    {:ok, rows} = DB.query("SELECT speciesid,name,menuname FROM Species")
    for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )
  end

  def menu_groups(species) do

    query = """
    select distinct InbredSet.id,InbredSet.Name,InbredSet.FullName
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

  def menu_datasets(species, group, type) do
    query = """
    select ProbeSetFreeze.Id,ProbeSetFreeze.Name,ProbeSetFreeze.FullName
    from ProbeSetFreeze, ProbeFreeze, InbredSet, Tissue, Species
    where
    Species.Name = '#{species}' and Species.Id = InbredSet.SpeciesId and
    InbredSet.Name = '#{group}' and
    ProbeSetFreeze.ProbeFreezeId = ProbeFreeze.Id and
    Tissue.Name = '#{type}' and
    ProbeFreeze.TissueId = Tissue.Id and ProbeFreeze.InbredSetId = InbredSet.Id and
    ProbeSetFreeze.confidentiality < 1 and ProbeSetFreeze.public > 0 order by
    ProbeSetFreeze.CreateTime desc
    """
    {:ok, rows} = DB.query(query)
    for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )
  end

end
