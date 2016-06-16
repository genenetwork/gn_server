defmodule GnServer.Logic.Assemble do

  alias GnServer.Data.Store, as: Store

  def menu_main do
    species = Store.menu_species
    nlist = Enum.map(species, fn(x) -> [_,sname,_]=x ;
        [sname,Store.menu_groups(sname)]
      end
    );
    groups = for [s,gs] <- nlist, into: %{}, do: { s, gs }

    types =
      for [s,gs] <- nlist, # for every species,group combi
        into: %{},
        do: { s, (
              for [_,gname,_] <- gs,
                into: %{},
                do: { gname, Store.menu_types(s,gname) } )
        }

    datasets =
        for [s, gs] <- nlist,
          into: %{},
          do: { s, (
              for [_,gname,_] <- gs,
                into: %{},
                do: { gname, Store.menu_types(s,gname) } )
        }
    IO.puts "^^^"
    %{ species: species,
       groups: groups,
       types: types,
       datasets: datasets }
  end

end
