defmodule GnServer.Logic.Assemble do

  alias GnServer.Data.Store, as: Store

  @doc """
  Assemble cross information
  """
  
  def cross(group) do
    Store.cross_get_species_name(group)
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
