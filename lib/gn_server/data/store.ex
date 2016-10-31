defmodule GnServer.Data.Store do

  @year 2013

  @moduledoc """
  This module provides low level calls (using Ecto) to the database -
  each call should return a simple list of records. For more complicated
  assembling check out the Assemble modules.

  All functions return lists of lists, rather than lists of
  tuples. Main reason is that tuples do not go nicely with JSON.
  """

  import Ecto.Query
  alias GnServer.Repo
  alias GnServer.Schema.Chr_Length
  alias GnServer.Schema.InbredSet
  alias GnServer.Schema.GenoFreeze
  alias GnServer.Schema.Geno
  alias GnServer.Schema.Phenotype
  alias GnServer.Schema.ProbeFreeze
  alias GnServer.Schema.ProbeSetFreeze
  alias GnServer.Schema.ProbeSet
  alias GnServer.Schema.ProbeSetXRef
  alias GnServer.Schema.ProbeSetData
  alias GnServer.Schema.ProbeSetSE
  alias GnServer.Schema.PublishData
  alias GnServer.Schema.PublishFreeze
  alias GnServer.Schema.PublishSE
  alias GnServer.Schema.PublishXRef
  alias GnServer.Schema.Publication
  alias GnServer.Schema.Species
  alias GnServer.Schema.Strain
  alias GnServer.Schema.StrainXRef
  alias GnServer.Schema.Tissue
  alias Ecto.Adapters.SQL

  # ==== Some private helper functions

  @doc """
  Convenience function transforms a string into an integer
  value when it can actually convert to int. Otherwise it leaves it as
  a string. Returns tuple {:string, s} or {:integer, i} tuple with
  type descriptor and value.
  """

  defp use_type(id) do
    try do
      { :integer, String.to_integer(id) }
    rescue
      _ in ArgumentError -> { :string, id }
    end
  end

  @doc """
  Authorize access based on inbred group - this will change
  soon
  """

  defp authorize_group(group_name) do
    if group_name != "BXD" do
      raise "Authorization error for " <> group_name
    end
    true
  end

  defp authorize_published_dataset(id) when is_integer(id) do
    query = from publishxref in PublishXRef,
      join: inbredset in InbredSet,
      on: publishxref."InbredSetId" == inbredset.id,
      join: phenotype in Phenotype,
      on: publishxref."PhenotypeId" == phenotype.id,
      join: publication in Publication,
      on: publishxref."PublicationId" == publication.id,
      distinct: true,
      select: { publishxref.id, phenotype.post_publication_abbreviation, phenotype.post_publication_description }, # , publication.pubmed_id,  publication.title, publication.year },
    where: inbredset."Name" == "BXD" and publishxref.id == ^id and (publication.year <= @year or not is_nil(publication."Pubmed_Id"))
    rows = Repo.all(query)
    # IO.inspect(rows)
    if Enum.count(rows) != 1 do
      raise "Authorization error (PublishData) for #{id}"
    end
  end

  @doc """
  Authorize access based on confidentiality and public
  fields
  """

  defp authorize_dataset(dataset_name) do
    {field_name, field_value} =
      case use_type(dataset_name) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name,s}
      end
    # Splitting out on ProbSet and PublishData
    if field_name == :id and field_value > 10_000 do
      authorize_published_dataset(field_value)
    else
      query = from x in ProbeSetFreeze,
        select: {x.confidentiality, x.public},
        where: field(x, ^field_name) == ^field_value,
        distinct: true

      rows = Repo.all(query)
      if Enum.count(rows) != 1 do
        raise "Access error (ProbeSet data) for #{dataset_name}"
      end

      [{confidentiality,public}] = rows
      if public < 2 or confidentiality > 0 do
        raise "Authorization error (ProbeSet data) for #{dataset_name}"
      end
    end
    true
  end

  # ==== Public database functions start here

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
    Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
  end

  # FIXME: forgot what the following is about...
  def group_info({:optimized, group}) do
    {inbredset_field, inbredset_value} =
      case use_type(group) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name, s}
      end
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
  end


  def datasets(group) do
    authorize_group(group)
    query1 = from probesetfreeze in ProbeSetFreeze,
      join: probefreeze in ProbeFreeze,
      on: probesetfreeze."ProbeFreezeId" == probefreeze."Id",
      join: tissue in Tissue,
      on: probefreeze."TissueId" == tissue."Id",
      join: inbredset in InbredSet,
      on:  probefreeze."InbredSetId" == inbredset."Id",
      where: inbredset."Name" == ^group and probesetfreeze.confidentiality < 1 and probesetfreeze.public > 0,
      select: {probesetfreeze.id, probesetfreeze."Name", probesetfreeze."FullName"},
      distinct: true

    list1 = Repo.all(query1) |> Enum.map(&(Tuple.to_list(&1)))

    query2 = from publishxref in PublishXRef,
      join: inbredset in InbredSet,
        on: publishxref."InbredSetId" == inbredset.id,
      join: phenotype in Phenotype,
        on: publishxref."PhenotypeId" == phenotype.id,
      join: publication in Publication,
        on: publishxref."PublicationId" == publication.id,
      distinct: true,
      select: { publishxref.id, phenotype.post_publication_abbreviation, phenotype.post_publication_description }, # , publication.pubmed_id,  publication.title, publication.year },
      where: inbredset."Name" == ^group and (publication.year <= @year or not is_nil(publication."Pubmed_Id"))
      # where: inbredset."Name" == ^group and (publication.year > 2010 and is_nil(publication."Pubmed_Id"))

      # where: inbredset."Name" == ^group and (publication.year <= 2010 or like(phenotype.post_publication_description,"%PMID%") # or like(phenotype.post_publication_description,"%DOI%"))

    list2 = Repo.all(query2) |> Enum.map(&(Tuple.to_list(&1)))
    # IO.inspect(list2)
    list1 ++ list2
  end

  def dataset_info(dataset_name) do
    authorize_dataset(dataset_name)
    {probesetfreeze_field, probesetfreeze_value} =
      case use_type(dataset_name) do
        { :integer, i } -> {:id, i}
        { :string, s }  -> {:Name, s}
      end
    if probesetfreeze_field==:id and probesetfreeze_value > 10_000 do
      dataset_info_publish_data(probesetfreeze_value)
    else

      query = from probesetfreeze in ProbeSetFreeze,
        join: probefreeze in ProbeFreeze,
        on: probesetfreeze."ProbeFreezeId" == probefreeze."Id",
        join: tissue in Tissue,
        on: probefreeze."TissueId" == tissue."Id",
        where: field(probesetfreeze, ^probesetfreeze_field) == ^probesetfreeze_value and probesetfreeze.public > 0,
        select: {probesetfreeze.id, probesetfreeze."Name", probesetfreeze."FullName",
                 probesetfreeze."ShortName", probesetfreeze."DataScale", probefreeze."TissueId",
                 tissue."Name", probesetfreeze.public, probesetfreeze.confidentiality}
      rec = Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
          [[id,name,full_name,short_name,data_scale,tissue_id,tissue_name,public,confidential]] = rec

          %{
            "dataset": "probeset",
            id:           id,
            name:         name,
            full_name:    full_name,
            short_name:   short_name,
            data_scale:   data_scale,
            tissue_id:    tissue_id,
            tissue:       tissue_name,
            public:       public,
            confidential: confidential
          }
    end
  end

  defp dataset_info_publish_data(id) do
    # authorize_dataset(id)
    query = from publishxref in PublishXRef,
      join: inbredset in InbredSet,
        on: publishxref."InbredSetId" == inbredset.id,
      join: phenotype in Phenotype,
        on: publishxref."PhenotypeId" == phenotype.id,
      join: publication in Publication,
        on: publishxref."PublicationId" == publication.id,
      distinct: true,
      select: { publishxref.id, phenotype.post_publication_abbreviation, phenotype.post_publication_description , publication.pubmed_id,  publication.title, publication.year },
      # where: inbredset."Name" == ^group and (publication.year <= 2010 or like(phenotype.post_publication_description,"%PMID%") # or like(phenotype.post_publication_description,"%DOI%"))
      where: inbredset."Name" == "BXD" and publishxref.id == ^id
      rec = Repo.all(query) |> Enum.map(&(Tuple.to_list(&1)))
          [[id,name,descr,pmid,title,year]] = rec

          %{ dataset:      "phenotype",
             id:           id,
             name:         name,
             descr:        descr,
             pmid:         pmid,
             title:        title,
             year:         year
             # data_scale:   data_scale,
             # tissue_id:    tissue_id,
             # tissue:       tissue_name,
             # public:       public,
             # confidential: confidential
          }
  end

  def phenotypes(dataset_name, start, stop) do
    authorize_dataset(dataset_name)

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

    # IO.puts("**** HERE #{dataset_name}")
    {id_type, id} = use_type(dataset_name)
    # IO.inspect {id_type, id}
    dataset_id =
      case {id_type, id} do
        { :integer, i } -> i
        # { :string, _ }  -> ( [[id2 | tail_]] = dataset_info(dataset_name)
        #                    id2 )
        { :string, _ }  -> ( %{ id: id2 } = dataset_info(dataset_name)
                             id2 )
      end
    # IO.inspect { dataset_id }

    if id_type==:integer and id > 10_000 do
      phenotypes_publish_data(id,start2,limit)
    else

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

      res = Repo.all(query)
      res2 = res |> Enum.map(from_tuple_to_structure)
      res2
    end
  end

  defp phenotypes_publish_data(id, start, limit) do
    "Not yet implemented phenotype info for publish_data id=#{id}"
  end

  def marker_info(species,marker) do
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
  end

  @doc """
  Fetch the trait from the PublishData table
  """

  def trait_published(id) when is_integer(id) do
    authorize_published_dataset(id)
    query = from publishxref in PublishXRef,
      join: inbredset in InbredSet,
        on: publishxref."InbredSetId" == inbredset.id,
      join: publishdata in PublishData,
        on: publishdata.id == publishxref.dataid,
      join: strain in Strain,
        on: publishdata.strainid == strain.id,
      left_join: publishse in PublishSE,
        on: publishdata.id == publishse.dataid and publishse.strainid == publishdata.strainid,
      distinct: true,
      select: [ publishdata.strainid, strain."Name", publishdata.value, publishse.error ],
      # Note: fixated to BXD (inbredset==1)
      where: publishxref.id == ^id and publishxref."InbredSetId" == 1
    rows = Repo.all(query)
    rows
  end

  def trait(id, marker \\ :classic) when is_integer(id) do
    case marker do
      :classic -> trait_published(id)
             _ -> raise "NYI"
    end
  end

  def trait(dataset_name,marker) do
    authorize_dataset(dataset_name)
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

  def trait(dataset_name,marker,group) do
    authorize_dataset(dataset_name)
    authorize_group(group)
    [[group_id | _ ] | _] = group_info({:original,group})
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
  end

  def menu_types(species, group) do
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
    count
  end

end
