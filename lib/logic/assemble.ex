defmodule GnServer.Logic.Assemble do

  alias GnServer.Data.Store, as: Store

  def menu_main do
    species = Store.menu_species
    nlist = Enum.map(species, fn(x) -> [_,sname,_]=x ;
        [sname,Store.menu_groups(sname)]
      end
    );
    groups = for [k,v] <- nlist, into: %{}, do: { k, v }

    IO.inspect nlist
    list =
      for [s,gs] <- nlist, # for every species,group combi
        do: Enum.map(gs, fn(g) -> # for every group
              [_,gname,_] = g
              ts = Store.menu_types(s,gname) # fetch types
              {s,gname,ts}
            end)
    # list contains a list of tuples {s,g,ts}
    types = %{}
    Enum.each(list, fn(tup) ->
      IO.inspect "***"
      IO.inspect(tup)
    end)

    %{ species: species,
       groups: groups,
       types: types }
  end

end
