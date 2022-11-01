#include "permission_manager.mligo"

[@view]
let is_minter (add, storage : address * storage) : bool =
    match (Big_map.find_opt add storage.minters ) with
            Some minter -> true
        |   None -> false

[@view]
let is_gallery (add, storage : address * storage) : bool =
    match (Big_map.find_opt add storage.galleries ) with
            Some gallery -> true
        |   None -> false
