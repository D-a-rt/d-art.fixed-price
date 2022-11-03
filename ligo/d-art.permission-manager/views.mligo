#include "permission_manager.mligo"

[@view]
let is_minter (add, storage : address * storage) : bool =
    match (Big_map.find_opt add storage.minters ) with
            Some _ -> True
        |   None -> False

[@view]
let is_gallery (add, storage : address * storage) : bool =
    match (Big_map.find_opt add storage.galleries ) with
            Some _ -> True
        |   None -> False
