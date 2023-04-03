#include "permission_manager.mligo"

[@view]
let is_minter (add, storage : address * storage) : bool =
    match (Big_map.find_opt add storage.minters ) with
            Some _ -> True
        |   None -> False

[@view]
let is_space_manager (add, storage : address * storage) : bool =
    match (Big_map.find_opt add storage.space_managers ) with
            Some _ -> True
        |   None -> False

[@view]
let is_auction_house_manager (add, storage : address * storage) : bool =
    match (Big_map.find_opt add storage.auction_house_managers ) with
            Some _ -> True
        |   None -> False

[@view]
let is_admin (add, storage : address * storage) : bool =
    if add = storage.admin_str.admin
    then True
    else False
