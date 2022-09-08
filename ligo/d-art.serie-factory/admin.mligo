type admin_factory_entrypoints =
    |   Add_minter of address
    |   Remove_minter of address
    |   Pause_serie_creation of bool
    |   Send_admin_invitation of admin_invitation_param
    |   Revoke_admin_invitation of admin_invitation_param

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : serie_factory_storage) : unit =
  if Tezos.sender <> storage.admin.admin
  then failwith "NOT_AN_ADMIN"
  else unit

let fail_if_sender_not_pending_admin (storage : serie_factory_storage) : unit =
  match storage.admin.pending_admin with
    None -> failwith "NOT_PENDING_ADMIN"
    | Some pa -> 
        if Tezos.sender <> pa
        then failwith "NOT_PENDING_ADMIN"
        else unit

let admin_main(param, storage : admin_factory_entrypoints * serie_factory_storage) : (operation list) * serie_factory_storage =
    let () = fail_if_not_admin storage in 
    match param with
        | Add_minter new_minter ->
            if Big_map.mem new_minter storage.minters
            then (failwith "ALREADY_MINTER" : operation list * serie_factory_storage)
            else ([]: operation list), { storage with minters = Big_map.add new_minter unit storage.minters}

        | Remove_minter old_minter_addess ->
            if Big_map.mem old_minter_addess storage.minters
            then ([]: operation list), { storage with minters = Big_map.remove old_minter_addess storage.minters }
            else (failwith "MINTER_NOT_FOUND" : operation list * serie_factory_storage)

        |   Pause_serie_creation boolean -> 
            ([] : operation list), { storage with origination_paused = boolean }

        |   Send_admin_invitation param ->
            ( []: operation list ), { storage with admin.pending_admin = Some(param.new_admin) }

        |   Revoke_admin_invitation param ->
            ([] : operation list ), { storage with admin.pending_admin = (None : address option) }
