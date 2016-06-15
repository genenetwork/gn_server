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
    h =
      for [s,gs] <- nlist, # for every species,group combi
        into: %{},
        do: { s, Enum.map(gs, fn(g) -> # for every group
              [_,gname,_] = g
              ts = Store.menu_types(s,gname) # fetch types
              %{gname => ts}
            end)}
        IO.inspect h
        IO.puts "^^^"
    %{ species: species,
       groups: groups,
       types: h }
  end

end
