defmodule GnServer.Schema.ProbeSet do
  use Ecto.Schema

  schema "probeset" do
    field :ChipId, :integer
    field :Name
    field :TargetId
    field :Symbol
    field :description
    field :Chr
    field :Mb, :integer
    field :alias
    field :GeneId
    field :GenbankId
    field :SNP, :integer
    field :BlatSeq
    field :TargetSeq
    field :UniGeneId
    field :Strand_Probe
    field :Strand_Gene
    field :OMIM
    field :comments
    field :Probe_set_target_region
    field :Probe_set_specificity, :integer
    field :Probe_set_BLAT_score, :integer
    field :Probe_set_Blat_Mb_start, :integer
    field :Probe_set_Blat_Mb_end, :integer
    field :Probe_set_strand
    field :Probe_set_Note_by_RW
    field :flag
    field :Symbol_H
    field :description_H
    field :chromosome_H
    field :MB_H, :integer
    field :alias_H
    field :GeneId_H
    field :chr_num, :integer
    field :name_num, :integer
    field :Probe_Target_Description
    field :RefSeq_TranscriptId
    field :Chr_mm8
    field :Mb_mm8, :integer
    field :Probe_set_Blat_Mb_start_mm8, :integer
    field :Probe_set_Blat_Mb_end_mm8, :integer
    field :HomoloGeneID
    field :ProteinID
    field :ProteinName
    field :Flybase_Id
    field :HMDB_ID
    field :Confidence, :integer
    field :ChEBI_ID, :integer
    field :ChEMBL_ID
    field :CAS_number
    field :PubChem_ID, :integer
    field :ChemSpider_ID, :integer
    field :UNII_ID
    field :EC_number
    field :KEGG_ID
    field :Molecular_Weight, :integer
    field :Nugowiki_ID, :integer
    field :Type
    field :Tissue
    field :PrimaryName
    field :SecondaryName
  end
  
end


    