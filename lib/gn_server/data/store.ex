# This module should only contain the MySQL calls to the backend to
# fetch data. Assembling more complex structures should happen in the
# Assemble modules.
#
# All functions return lists of lists, rather than lists of
# tuples. Main reason is that tuples do not go nicely with JSON.

defmodule GnServer.Data.Store do

  # alias GnServer.Backend.MySQL, as: DB
  import Ecto.Query
  alias GnServer.Repo
  alias GnServer.Schema.Species
  alias GnServer.Schema.ProbeSetFreeze
  alias GnServer.Schema.InbredSet
  alias GnServer.Schema.ProbeFreeze
  alias GnServer.Schema.GenoFreeze
  alias GnServer.Schema.PublishFreeze
  alias GnServer.Schema.Tissue
  alias GnServer.Schema.Geno
  alias GnServer.Schema.Chr_Length
  alias GnServer.Schema.ProbeSet
  alias GnServer.Schema.ProbeSetXRef
  alias GnServer.Schema.ProbeSetData
  alias GnServer.Schema.ProbeSetSE
  alias GnServer.Schema.Strain
  alias GnServer.Schema.StrainXRef
  alias Ecto.Adapters.SQL

  defp use_type(id) do
    try do
      { :integer, String.to_integer(id) }
    rescue
      _ in ArgumentError -> { :string, id }
    end
  end

  defp authorize_group(group_name) do
    if group_name != "BXD" do
      raise "Authorization error for " <> group_name
    end
  end

  defp authorize_dataset(dataset_name) do
    {field_name, field_value} =
      case use_type(dataset_name) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name,s}
      end
#     query = """
# SELECT DISTINCT D.confidentiality,D.public FROM ProbeSetFreeze AS D
# WHERE #{subq}
# """

    query = from x in ProbeSetFreeze,
      select: {x.confidentiality, x.public},
      where: field(x, ^field_name) == ^field_value,
      distinct: true

    rows = Repo.all(query)
    if Enum.count(rows) != 1 do
      raise "Access error"
    end

    [{confidentiality,public}] = rows
    if public < 2 or confidentiality > 0 do
      raise "Authorization error"
    end
  end

  def species do
    query = from s in Species,
      select: {s."SpeciesId", s."Name", s."FullName"}
    Repo.all(query) |> Enum.map(&(Tuple.to_list &1))
  end

  def groups(species) do
    {species_field, species_value} =
      case use_type(species) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name, s}
      end

    # note this query can be simplified
#     query = """
# SELECT distinct InbredSet.id,InbredSet.Name,InbredSet.FullName
# FROM InbredSet,Species,ProbeFreeze,GenoFreeze,PublishFreeze
# WHERE #{subq}
# and InbredSet.SpeciesId = Species.Id and InbredSet.Name != 'BXD300'
# and (PublishFreeze.InbredSetId = InbredSet.Id
#      or GenoFreeze.InbredSetId = InbredSet.Id
#      or ProbeFreeze.InbredSetId = InbredSet.Id)
# """
    query = from species in Species,
      join: inbredset in InbredSet,
      on: species.id == inbredset."SpeciesId",
      left_join: publishfreeze in PublishFreeze,
      on: publishfreeze."InbredSetId" == inbredset.id,
      left_join: genofreeze in GenoFreeze,
      on: genofreeze."InbredSetId" == inbredset.id,
      left_join: probefreeze in ProbeFreeze,
      on: probefreeze."InbredSetId" == inbredset.id,
      where: field(species, ^species_field) == ^species_value and inbredset."Name" != "BXD300",
      select: {inbredset.id,inbredset."Name",inbredset."FullName"},
      distinct: true

    Repo.all(query) |> Enum.map(&(Tuple.to_list &1))
  end

  def group_info({:original, group}) do
    {inbredset_field, inbredset_value} =
      case use_type(group) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name, s}
      end
#     query = "
# SELECT DISTINCT Species.speciesid,Species.Name,C.InbredSetid,C.name,C.mappingmethodid,C.genetictype
# FROM Species, InbredSet as C
# WHERE #{subq} and C.SpeciesId = Species.Id"
    query = from species in Species,
      join: inbredset in InbredSet,
      on: species.id == inbredset."SpeciesId",
      where: field(inbredset, ^inbredset_field) == ^inbredset_value,
      select: {inbredset."InbredSetId",
               inbredset."Name",
               species."SpeciesId",
               species."Name",
               inbredset."MappingMethodId",
               inbredset."GeneticType"},
      distinct: true
    # for r <- rows, do: ( {species_id,species,group_id,group_name,method_id,genetic_type} = r; [group_id,group_name,species_id,species,method_id,genetic_type] )
    Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
  end

  def chr_info(dataset_name) do
    {inbredset_field, inbredset_value} =
      case use_type(dataset_name) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name, s}
      end

    query = from chr_length in Chr_Length,
      join: inbredset in InbredSet,
      on: chr_length."SpeciesId" == inbredset."SpeciesId",
      where: field(inbredset, ^inbredset_field) == ^inbredset_value,
      select: {chr_length."Name", chr_length."Length"},
      order_by: chr_length."OrderId"

    Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
#       query = """
# SELECT Chr_Length.Name, Length
# FROM Chr_Length, InbredSet as C
# WHERE #{subq}
# AND Chr_Length.SpeciesId = C.SpeciesId
# ORDER BY Chr_Length.OrderId
#       """
#     {:ok, rows} = DB.query(query)
#     for r <- rows, do: ( {chr_name,chr_len} = r; [chr_name,chr_len] )
  end

  def group_info({:optimized, group}) do
    {inbredset_field, inbredset_value} =
      case use_type(group) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name, s}
      end
#     query = "
# SELECT DISTINCT Species.speciesid,Species.Name,C.InbredSetid,C.name,C.mappingmethodid,C.genetictype
# FROM Species, InbredSet as C
# WHERE #{subq} and C.SpeciesId = Species.Id"

    # query_species = from species in Species,
    #   join: inbredset in InbredSet,
    #   on: field(inbredset, ^inbredset_field) == ^inbredset_value and species.id == inbredset."SpeciesId",
    #   #where: field(inbredset, ^inbredset_field) == ^inbredset_value,
    #   select: {inbredset."InbredSetId",
    #            inbredset."Name",
    #            species."SpeciesId",
    #            species."Name",
    #            inbredset."MappingMethodId",
    #            inbredset."GeneticType"},
    #   distinct: true
    # # for r <- rows, do: ( {species_id,species,group_id,group_name,method_id,genetic_type} = r; [group_id,group_name,species_id,species,method_id,genetic_type] )
    # species_results = Repo.all(query_species)

    # query_chr_length = from chr_length in Chr_Length,
    #   join: inbredset in InbredSet,
    #   on:  field(inbredset, ^inbredset_field) == ^inbredset_value and chr_length."SpeciesId" == inbredset."SpeciesId",
    #   # where: field(inbredset, ^inbredset_field) == ^inbredset_value,
    #   select: {chr_length."Name", chr_length."Length"},
    #   order_by: chr_length."OrderId"

# #JSON
# query="""
# SELECT InbredSet.InbredSetId, InbredSet.Name, Species.SpeciesId, Species.Name, InbredSet.MappingMethodId, InbredSet.GeneticType,
# GROUP_CONCAT(DISTINCT JSON_OBJECT(Chr_Length.Name, Chr_Length.Length) ORDER BY Chr_Length.OrderId SEPARATOR ',') as Chrs
# FROM Species
# JOIN InbredSet
# ON Species.Id = InbredSet.SpeciesId and InbredSet.Name = "BXD"
# JOIN Chr_Length
# ON Chr_Length.SpeciesId = InbredSet.SpeciesId
# GROUP BY InbredSet.InbredSetId, InbredSet.Name,Species.SpeciesId, Species.Name,InbredSet.MappingMethodId, InbredSet.GeneticType
# """


query="""
SELECT InbredSet.InbredSetId, InbredSet.Name, Species.SpeciesId, Species.Name, InbredSet.MappingMethodId, InbredSet.GeneticType,
GROUP_CONCAT(DISTINCT CONCAT_WS(',',Chr_Length.Name, Chr_Length.Length) ORDER BY Chr_Length.OrderId SEPARATOR ' ') as Chrs
FROM Species
JOIN InbredSet
ON Species.Id = InbredSet.SpeciesId and InbredSet.#{inbredset_field} = "#{inbredset_value}"
JOIN Chr_Length
ON Chr_Length.SpeciesId = InbredSet.SpeciesId
GROUP BY InbredSet.InbredSetId, InbredSet.Name,Species.SpeciesId, Species.Name,InbredSet.MappingMethodId, InbredSet.GeneticType
"""

{:ok,
 %Mariaex.Result{columns: ["InbredSetId", "Name", "SpeciesId", "Name",
   "MappingMethodId", "GeneticType", "Chrs"], command: :select,
  connection_id: nil, last_insert_id: nil, num_rows: 1,
  rows: [data]}} = Ecto.Adapters.SQL.query(Repo, String.replace(query,"\n"," "), []) # would be better to use the parameters in the custom query

data
  end

  def datasets(group) do
    authorize_group(group)
#     query = """
# SELECT DISTINCT D.Id,D.Name,D.FullName
# FROM ProbeSetFreeze AS D, ProbeFreeze as D2, InbredSet, Tissue, Species
# WHERE
#     InbredSet.Name = '#{group}' and
#     D.ProbeFreezeId = D2.Id
#     AND D2.TissueId = Tissue.Id
#     AND D2.InbredSetId = InbredSet.Id
#     AND D.confidentiality < 1
#     AND D.public > 0
# """
    query = from probesetfreeze in ProbeSetFreeze,
      join: probefreeze in ProbeFreeze,
      on: probesetfreeze."ProbeFreezeId" == probefreeze."Id",
      join: tissue in Tissue,
      on: probefreeze."TissueId" == tissue."Id",
      join: inbredset in InbredSet,
      on:  probefreeze."InbredSetId" == inbredset."Id",
      where: inbredset."Name" == ^group and probesetfreeze.confidentiality < 1 and probesetfreeze.public > 0,
      select: {probesetfreeze.id, probesetfreeze."Name", probesetfreeze."FullName"},
      distinct: true

      Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))

    # {:ok, rows} = DB.query(query)
    # for r <- rows, do: ( {id,name,full_name} = r ; [id,name,full_name] )
  end

  def dataset_info(dataset_name) do
    authorize_dataset(dataset_name)
    {probesetfreeze_field, probesetfreeze_value} =
      case use_type(dataset_name) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name, s}
      end

#     query = """
# SELECT D.Id, D.Name, D.FullName, D.ShortName, D.DataScale, D2.TissueId, Tissue.Name, D.public, D.confidentiality
# FROM ProbeSetFreeze as D, ProbeFreeze as D2, Tissue
# WHERE #{subq}
#     AND D.public > 0
#     AND D.ProbeFreezeId = D2.Id
#     AND D2.TissueId = Tissue.Id
#     """
#     {:ok, rows} = DB.query(query)
#     for r <- rows, do: ( {id,name,full_name,short_name,data_scale,tissue_id,tissue_name,public,confidential} = r; [id,name,full_name,short_name,data_scale,tissue_id,tissue_name,public,confidential] )

    query = from probesetfreeze in ProbeSetFreeze,
      join: probefreeze in ProbeFreeze,
      on: probesetfreeze."ProbeFreezeId" == probefreeze."Id",
      join: tissue in Tissue,
      on: probefreeze."TissueId" == tissue."Id",
      where: field(probesetfreeze, ^probesetfreeze_field) == ^probesetfreeze_value and probesetfreeze.public > 0,
      select: {probesetfreeze.id, probesetfreeze."Name", probesetfreeze."FullName",
               probesetfreeze."ShortName", probesetfreeze."DataScale", probefreeze."TissueId",
               tissue."Name", probesetfreeze.public, probesetfreeze.confidentiality}
    Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
  end

  def phenotypes(dataset_name, start, stop) do
    authorize_dataset(dataset_name)
    dataset_id =
      case use_type(dataset_name) do
        { :integer, i } -> i
        { :string, _ }  -> ( [[id | tail_]] = dataset_info(dataset_name)
                           id )
      end

    start2 =
      if start == nil do
        0
      else
        start
      end

    stop2 =
      if stop == nil do
        100
      else
        stop
      end

    limit = stop2 - start2 + 1
#     query = """
# SELECT distinct ProbeSet.Name,
#   ProbeSetXRef.Mean, ProbeSetXRef.LRS,
#   ProbeSetXRef.PVALUE, ProbeSetXRef.additive, ProbeSetXRef.locus, ProbeSet.Chr_num,
#   ProbeSet.Mb, ProbeSet.Symbol,
#   ProbeSet.name_num
# FROM ProbeSetXRef, ProbeSet
# WHERE ProbeSet.Id = ProbeSetXRef.ProbeSetId
#   and ProbeSetXRef.ProbeSetFreezeId = #{dataset_id}
#   ORDER BY ProbeSet.symbol ASC LIMIT #{limit}
#     """
#     {:ok, rows} = DB.query(query)
    # for r <- rows, do: ( {name,mean,lrs,pvalue,additive,locus,chr,mb,symbol,name_num} = r ;
    #   %{ name: name,
    #      name_id: name_num,
    #      mean: mean,
    #      "MAX_LRS": lrs,
    #      "p_value": pvalue,
    #      additive: additive,
    #      locus: locus,
    #      chr: chr,
    #      "Mb": mb,
    #      symbol: symbol
    #   })

    query = from probeset in ProbeSet,
      join: probesetxref in ProbeSetXRef,
      on: probeset.id == probesetxref."ProbeSetId",
      where: probesetxref."ProbeSetFreezeId" == ^dataset_id,
      select: {probeset."Name", probesetxref.mean, probesetxref."LRS",
               probesetxref.pValue, probesetxref.additive, probesetxref."Locus",
               probeset.chr_num, probeset."Mb", probeset."Symbol", probeset.name_num},
      distinct: true,
      order_by: [asc: probeset."symbol", desc: probesetxref."LRS"],
      limit: ^limit

    from_tuple_to_structure = fn(query_result) ->
      {name,mean,lrs,pvalue,additive,locus,chr,mb,symbol,name_num} = query_result
      %{ name: name,
         name_id: name_num,
         mean: mean,
         "MAX_LRS": lrs,
         "p_value": pvalue,
         additive: additive,
         locus: locus,
         chr: chr,
         "Mb": mb,
         symbol: symbol
      }
    end

    Repo.all(query) |> Enum.map(from_tuple_to_structure)

  end

  def marker_info(species,marker) do
#       query = """
# SELECT Geno.Chr, Geno.Mb, Species.Id,Geno.source FROM Geno, Species
# WHERE Species.Name = '#{species}'
# AND Geno.Name = '#{marker}'
#      """
     query = from tab_species in Species,
     join: geno in Geno,
     on: tab_species."SpeciesId" == geno."SpeciesId",
     where: tab_species."Name" == ^species and geno."Name" == ^marker,
     select: {geno."Chr", geno."Mb", tab_species.id, geno."Source"}

    # {:ok, rows} = DB.query(query)

    from_tuple_to_structure = fn(query_result) ->
      {chr_name,chr_len,species_id,source} = query_result
      %{
        species: species,
        species_id: species_id,
        source: source,
        marker: marker,
        chr:     chr_name,
        chr_len: chr_len
      }
    end

    Repo.all(query) |> Enum.map(from_tuple_to_structure)


    # for r <- rows, do: ( {chr_name,chr_len,species_id,source} = r;
    #   %{
    #     species: species,
    #     species_id: species_id,
    #     source: source,
    #     marker: marker,
    #     chr:     chr_name,
    #     chr_len: chr_len
    #   } )
  end


  def phenotype_info(dataset_name,marker) do
    authorize_dataset(dataset_name)
    # The GN1 querly looks like
    # query = "SELECT Strain.Name, %sData.value from %sData, Strain, %s, %sXRef WHERE %s.Name = '%s' and %sXRef.%sId = %s.Id and %sXRef.%sFreezeId = %d and  %sXRef.DataId = %sData.Id and %sData.StrainId = Strain.Id order by Strain.Id"
    # but it does not pick up the stderr.
      # query = """
# SELECT DISTINCT Strain.id, Strain.Name, ProbeSetData.value, ProbeSetSE.error,
  # ProbeSetData.Id
# FROM (ProbeSetData, ProbeSetFreeze, Strain, ProbeSet, ProbeSetXRef)
# LEFT JOIN ProbeSetSE on (ProbeSetSE.DataId = ProbeSetData.Id
  # AND ProbeSetSE.StrainId = ProbeSetData.StrainId)
# WHERE ProbeSet.Name = '#{marker}'
  # AND ProbeSetXRef.ProbeSetId = ProbeSet.Id
  # AND ProbeSetXRef.ProbeSetFreezeId = ProbeSetFreeze.Id
  # AND ProbeSetFreeze.Name = '#{dataset_name}'
  # AND ProbeSetXRef.DataId = ProbeSetData.Id
  # AND ProbeSetData.StrainId = Strain.Id
  # ORDER BY Strain.Id
      # """
    # IO.puts(query)
    # {:ok, rows} = DB.query(query)
    # for r <- rows, do: ( {strain_id,strain_name,value,stderr,_} = r;
    #   [strain_id,strain_name,value,stderr]
    # )

    query = from probesetdata in ProbeSetData,
      left_join: probesetse in ProbeSetSE,
      on: probesetdata.id == probesetse."DataId" and probesetdata."StrainId" == probesetse."StrainId",
      join: strain in Strain,
      on: probesetdata."StrainId" == strain.id,
      join: probesetxref in ProbeSetXRef,
      on: probesetdata.id == probesetxref."DataId",
      join: probeset in ProbeSet,
      on: probesetxref."ProbeSetId" == probeset.id,
      join: probesetfreeze in ProbeSetFreeze,
      on: probesetxref."ProbeSetFreezeId" == probesetfreeze.id,
      where: probeset."Name" == ^marker and probesetfreeze."Name" == ^dataset_name,
      select: {strain.id, strain."Name", probesetdata.value, probesetse.error, probesetdata.id},
      distinct: true,
      order_by: strain.id

    from_tuple_to_structure = fn(query_result) ->
      {strain_id,strain_name,value,stderr,_} = query_result
      [strain_id,strain_name,Float.round(value,3),stderr]
    end

    Repo.all(query) |> Enum.map(from_tuple_to_structure)

  end

  def phenotype_info(dataset_name,marker,group) do
    authorize_dataset(dataset_name)
    authorize_group(group)
    [[group_id | _ ] | _] = group_info({:original,group})
    # query = """
# SELECT DISTINCT Strain.Id, StrainXRef.InbredSetId, Strain.Name, ProbeSetData.value, ProbeSetSE.error,
  # ProbeSetData.Id
# FROM (ProbeSetData as V, ProbeSetFreeze as D, ProbeFreeze as D2, Strain, StrainXRef as SX, ProbeSet, ProbeSetXRef as Locus)
# LEFT JOIN ProbeSetSE on (ProbeSetSE.DataId = ProbeSetData.Id
#   AND ProbeSetSE.StrainId = ProbeSetData.StrainId)
# WHERE ProbeSet.Name = '#{marker}'
  # AND ProbeSetXRef.ProbeSetId = ProbeSet.Id
  # AND ProbeSetXRef.ProbeSetFreezeId = ProbeSetFreeze.Id
  # AND StrainXRef.StrainId = Strain.Id
  # AND StrainXRef.InbredSetId = #{group_id}
  # AND ProbeSetFreeze.Name = '#{dataset_name}'
  # AND ProbeSetXRef.DataId = ProbeSetData.Id
  # AND ProbeSetData.StrainId = Strain.Id
  # AND StrainXRef.StrainId = Strain.Id
  # ORDER BY Strain.Id
    # """

    # IO.puts(query)
    # {:ok, rows} = DB.query(query)
    # for r <- rows, do: ( {strain_id,_,strain_name,value,stderr,_} = r;
    #   [strain_id,strain_name,value,stderr]
    # )

    query = from probesetdata in ProbeSetData,
      left_join: probesetse in ProbeSetSE,
      on: probesetdata.id == probesetse."DataId" and probesetdata."StrainId" == probesetse."StrainId",
      join: probesetxref in ProbeSetXRef,
      on: probesetdata.id == probesetxref."DataId",
      join: probeset in ProbeSet,
      on: probesetxref."ProbeSetId" == probeset.id,
      join: probesetfreeze in ProbeSetFreeze,
      on: probesetxref."ProbeSetFreezeId" == probesetfreeze.id,
      join: strain in Strain,
      on: probesetdata."StrainId" == strain.id,
      join: strainxref in StrainXRef,
      on: strain.id == strainxref."StrainId",
      where: probeset."Name" == ^marker and probesetfreeze."Name" == ^dataset_name and strainxref."InbredSetId" == ^group_id,
      select: {strain.id, strainxref."InbredSetId", strain."Name", probesetdata.value, probesetse.error, probesetdata.id},
      distinct: true,
      order_by: strain.id
    from_tuple_to_structure = fn(query_result) ->
      {strain_id,_,strain_name,value,stderr,_} = query_result
      [strain_id,strain_name,Float.round(value,3),stderr]
    end

    Repo.all(query) |> Enum.map(from_tuple_to_structure)
  end

  def menu_species do
    query = from species in Species,
      select: {species."SpeciesId", species."Name", species."MenuName"}
    # {:ok, rows} = DB.query("SELECT speciesid,name,menuname FROM Species")
    # for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )
    Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
  end

  def menu_groups(species) do

    query = "select distinct InbredSet.id,InbredSet.Name,InbredSet.FullName from InbredSet,Species,ProbeFreeze,GenoFreeze,PublishFreeze where Species.Name = ? and InbredSet.SpeciesId = Species.Id and InbredSet.Name != 'BXD300' and (PublishFreeze.InbredSetId = InbredSet.Id or GenoFreeze.InbredSetId = InbredSet.Id or ProbeFreeze.InbredSetId = InbredSet.Id) order by InbredSet.Name"
# group by InbredSet.Name
    {:ok, %Mariaex.Result{columns: _columns, command: _command, connection_id: _connection_id, last_insert_id: _last_insert_id, num_rows: _num_rows, rows: rows }} = SQL.query(Repo, query, [species])
    rows
    # {:ok, rows} = DB.query(query)
    # for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )
  end

  def menu_types(species, group) do
    # query = """
    # select distinct Tissue.Name
    # from ProbeFreeze,ProbeSetFreeze,InbredSet,Tissue,Species
    # where Species.Name = '#{species}' and
      # Species.Id = InbredSet.SpeciesId and
      # InbredSet.Name = '#{group}' and
      # ProbeFreeze.TissueId = Tissue.Id and
      # ProbeFreeze.InbredSetId = InbredSet.Id and
      # ProbeSetFreeze.ProbeFreezeId = ProbeFreeze.Id and
      # ProbeSetFreeze.public > 0
      # order by Tissue.Name
    # """
    # {:ok, rows} = DB.query(query)
    # for r <- rows, do: ( {tissue} = r; [tissue] )

    query = from tab_species in Species,
      join: inbredset in InbredSet,
      on: tab_species.id == inbredset."SpeciesId",
      join: probefreeze in ProbeFreeze,
      on: probefreeze."InbredSetId" == inbredset.id,
      join: tissue in Tissue,
      on: probefreeze."TissueId" == tissue.id,
      join: probesetfreeze in ProbeSetFreeze,
      on: probesetfreeze."ProbeFreezeId" == probefreeze.id,
      where: tab_species."Name" == ^species and
             inbredset."Name" == ^group and
             probesetfreeze.public > 0,
      select: {tissue."Name"},
      distinct: true,
      order_by: tissue."Name"

      Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
  end

  def menu_datasets(species, group, type) do
    # query = """
    # select ProbeSetFreeze.Id,ProbeSetFreeze.Name,ProbeSetFreeze.FullName
    # from ProbeSetFreeze,
    # ProbeFreeze,
    # InbredSet,
    # Tissue,
     # Species
    # where
    # Species.Name = '#{species}' and
    # Species.Id = InbredSet.SpeciesId and
    # InbredSet.Name = '#{group}' and
    # ProbeSetFreeze.ProbeFreezeId = ProbeFreeze.Id and
    # Tissue.Name = '#{type}' and
    # ProbeFreeze.TissueId = Tissue.Id and
     # ProbeFreeze.InbredSetId = InbredSet.Id and
    # ProbeSetFreeze.confidentiality < 1 and
    # ProbeSetFreeze.public > 0
    # order by ProbeSetFreeze.CreateTime desc
    # """
    # {:ok, rows} = DB.query(query)
    # for r <- rows, do: ( {id,name,fullname} = r; [id,name,fullname] )

    query = from tab_species in Species,
      join: inbredset in InbredSet,
      on: tab_species.id == inbredset."SpeciesId",
      join: probefreeze in ProbeFreeze,
      on: inbredset.id == probefreeze."InbredSetId",
      join: probesetfreeze in ProbeSetFreeze,
      on: probefreeze.id == probesetfreeze."ProbeFreezeId",
      join: tissue in Tissue,
      on: probefreeze."TissueId" == tissue.id,
      where: tab_species."Name" == ^species and
             inbredset."Name" == ^group and
             tissue."Name" == ^type and
             probesetfreeze.confidentiality < 1 and
             probesetfreeze.public > 0,
      select: {probesetfreeze.id, probesetfreeze."Name", probesetfreeze."FullName"},
      order_by: [desc: probesetfreeze."CreateTime"]

    Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
  end

  def snp_count(chr_name, start_mb, step_mb, strain_id1, strain_id2) do
    query = """
    select
        count(*) from BXDSnpPosition
    where
        Chr = '#{chr_name}' AND Mb >= #{start_mb} AND Mb < #{start_mb+step_mb} AND
        StrainId1 = #{strain_id1} AND StrainId2 = #{strain_id2}
    """
    {:ok, result} = SQL.query(Repo, query, [])
    [[count]] = result.rows
    # IO.inspect(result)
    count
  end

end
