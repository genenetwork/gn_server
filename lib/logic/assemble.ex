defmodule GnServer.Logic.Assemble do

  alias GnServer.Data.Store, as: Store
  
  def menu_main do
    species = Store.menu_species
    nlist = Enum.map(species, fn(x) -> [_,sname,_]=x ;
        [sname,Store.menu_groups(sname)]
      end
    );

    IO.inspect "SHOW"
    IO.inspect nlist
    hash = for [k,v] <- nlist, into: %{}, do: { k, v }
     
    %{ species: species,
       groups: hash}
  end
  
end
