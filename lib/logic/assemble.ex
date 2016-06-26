defmodule GnServer.Logic.Assemble do

  alias GnServer.Data.Store, as: Store

  @doc """
  Assemble cross information
  """

  def group_info(group) do
    [[group_id,group_name,species_id,species,method_id,genetic_type]] = Store.group_info(group)
    %{ group_id:             group_id,
       group:                group_name,
       species_id:           species_id,
       species:              species,
       mapping_method_id:    String.to_integer(method_id),
       genetic_type:         genetic_type
    }
  end

  def dataset_info(dataset_name) do
    [[id,name,full_name,short_name,data_scale,tissue_id,tissue_name,public,confidential]] = Store.dataset_info(dataset_name)
    %{ id:           id,
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

  def menu_main do
    species = Store.menu_species
    nlist = Enum.map(species, fn(x) -> [_,sname,menu]=x ;
        [sname,menu,Store.menu_groups(sname)]
      end
    );
    groups = for [s,_,gs] <- nlist, into: %{}, do: { s, gs }

    types =
      for [s,smenu,gs] <- nlist, # for every species,group combi
        into: %{},
        do: { s, %{ "menu" => smenu , "types" => (
              for [_,gname,_] <- gs,
                into: %{},
                do: { gname, Store.menu_types(s,gname) } ) }
        }

    datasets =
        for [s, smenu, gs] <- nlist,
          into: %{},
          do: { s, (
              for [_,gname,_] <- gs,
                into: %{},
                do: { gname, (
                   for [t] <- Store.menu_types(s,gname),
                     into: %{},
                     do: { t, Store.menu_datasets(s,gname,t) }
               )}

        )}
    %{ # species: species,
       groups: groups,
       menu: types,
       datasets: datasets }
  end

end
