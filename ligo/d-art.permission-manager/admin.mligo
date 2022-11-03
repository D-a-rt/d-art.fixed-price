type admin_factory_entrypoints =
    |   Add_minter of address
    |   Remove_minter of address
    |   Add_gallery of address
    |   Remove_gallery of address
    |   Send_admin_invitation of admin_invitation_param
    |   Revoke_admin_invitation of unit

(* Fails if sender is not admin *)
[@inline]
let fail_if_not_admin (storage : storage) : unit = if Tezos.get_sender() <> storage.admin.admin then failwith "NOT_AN_ADMIN"

let fail_if_sender_not_pending_admin (storage : storage) : unit =
  match storage.admin.pending_admin with
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
                if Big_map.mem old_minter_addess storage.minters
                then ([]: operation list), { storage with minters = Big_map.remove old_minter_addess storage.minters }
                else (failwith "MINTER_NOT_FOUND" : operation list * storage)

        |   Add_gallery new_gallery ->
                if Big_map.mem new_gallery storage.galleries
                then (failwith "ALREADY_GALLERY" : operation list * storage)
                else ([]: operation list), { storage with galleries = Big_map.add new_gallery unit storage.galleries}

        |   Remove_gallery old_gallery ->
                if Big_map.mem old_gallery storage.galleries
                then ([]: operation list), { storage with galleries = Big_map.remove old_gallery storage.galleries }
                else (failwith "GALLERY_NOT_FOUND" : operation list * storage)

        |   Send_admin_invitation param ->
                ( []: operation list ), { storage with admin.pending_admin = Some(param.new_admin) }

        |   Revoke_admin_invitation _ ->
                ([] : operation list ), { storage with admin.pending_admin = (None : address option) }
