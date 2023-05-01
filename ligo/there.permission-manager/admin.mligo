type admin_factory_entrypoints =
    |   Add_minter of address
    |   Remove_minter of address
    |   Add_space_manager of address
    |   Remove_space_manager of address
    |   Add_auction_house_manager of address
    |   Remove_auction_house_manager of address
    |   Send_admin_invitation of admin_invitation_param
    |   Revoke_admin_invitation of unit

(* Fails if sender is not admin *)
[@inline]
let fail_if_not_admin (storage : storage) : unit = if Tezos.get_sender() <> storage.admin_str.admin then failwith "NOT_AN_ADMIN"

let fail_if_sender_not_pending_admin (storage : storage) : unit =
  match storage.admin_str.pending_admin with
    None -> failwith "NOT_PENDING_ADMIN"
    | Some pa -> if Tezos.get_sender() <> pa then failwith "NOT_PENDING_ADMIN"

let admin_main(param, storage : admin_factory_entrypoints * storage) : (operation list) * storage =
    let () = fail_if_not_admin storage in 
    match param with
        |   Add_minter new_minter ->
                if Big_map.mem new_minter storage.minters
                then (failwith "ALREADY_MINTER" : operation list * storage)
                else ([]: operation list), { storage with minters = Big_map.add new_minter unit storage.minters}

        |   Remove_minter old_minter_addess ->
                ([]: operation list), { storage with minters = Big_map.remove old_minter_addess storage.minters }

        |   Add_space_manager new_space_manager ->
                if Big_map.mem new_space_manager storage.space_managers
                then (failwith "ALREADY_SPACE_MANAGER" : operation list * storage)
                else ([]: operation list), { storage with space_managers = Big_map.add new_space_manager unit storage.space_managers}

        |   Remove_space_manager old_space_manager ->
                ([]: operation list), { storage with space_managers = Big_map.remove old_space_manager storage.space_managers }

        |   Add_auction_house_manager new_auction_house_manager ->
                if Big_map.mem new_auction_house_manager storage.auction_house_managers
                then (failwith "ALREADY_AUCTION_HOUSE_MANAGER" : operation list * storage)
                else ([]: operation list), { storage with auction_house_managers = Big_map.add new_auction_house_manager unit storage.auction_house_managers}

        |   Remove_auction_house_manager old_auction_house_manager ->
                ([]: operation list), { storage with auction_house_managers = Big_map.remove old_auction_house_manager storage.auction_house_managers }

        |   Send_admin_invitation param ->
                ( []: operation list ), { storage with admin_str.pending_admin = Some(param.new_admin) }

        |   Revoke_admin_invitation _ ->
                ([] : operation list ), { storage with admin_str.pending_admin = (None : address option) }