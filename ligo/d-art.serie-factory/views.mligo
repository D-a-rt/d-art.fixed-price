#include "serie_factory.mligo"

[@view]
let is_minter (add, storage : address * serie_factory_storage) : bool =
    match (Big_map.find_opt add storage.minters ) with
            Some minter -> true
        |   None -> false
