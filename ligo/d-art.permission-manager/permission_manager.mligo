#include "interface.mligo"

[@inline]
let assert_msg (condition, msg : bool * string ) : unit = if (not condition) then failwith(msg) else unit

[@inline]
let fail_if_not_admin (storage : storage) : unit = if Map.mem (Tezos.get_sender()) storage.admins then unit else failwith "NOT_AN_ADMIN"

type art_permission_manager = 
    |   Add_minter of address
    |   Remove_minter of address
    |   Add_gallery of address
    |   Remove_gallery of address
    |   Add_admin of address
    |   Remove_admin of address


let permission_manager_main (param, storage : art_permission_manager * storage)  : (operation list) * storage = 
    let () : unit = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    let () = fail_if_not_admin storage in 
    match param with
        |   Add_minter new_minter ->
                if Big_map.mem new_minter storage.minters
                then (failwith "ALREADY_MINTER" : operation list * storage)
                else ([]: operation list), { storage with minters = Big_map.add new_minter unit storage.minters}

        |   Remove_minter old_minter_addess ->
                ([]: operation list), { storage with minters = Big_map.remove old_minter_addess storage.minters }

        |   Add_gallery new_gallery ->
                if Big_map.mem new_gallery storage.galleries
                then (failwith "ALREADY_GALLERY" : operation list * storage)
                else ([]: operation list), { storage with galleries = Big_map.add new_gallery unit storage.galleries}

        |   Remove_gallery old_gallery ->
                ([]: operation list), { storage with galleries = Big_map.remove old_gallery storage.galleries }

        |   Add_admin add ->
            if Map.mem add storage.admins
            then (failwith "ALREADY_ADMIN" : operation list * storage)
            else ([] : operation list), { storage with admins = Map.add add unit storage.admins; }
        
        |   Remove_admin add ->
            if Map.size storage.admins > 1n
            then ([] : operation list), { storage with admins = Map.remove add storage.admins}
            else (failwith "MINIMUM_1_ADMIN" : operation list * storage)

