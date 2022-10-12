#if WILL_ORIGINATE_FROM_FACTORY

type revoke_minting_param =
[@layout:comb]
{
  revoke: bool
}

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : admin_storage) : unit =
  if Tezos.sender <> storage.admin
  then failwith "NOT_AN_ADMIN"
  else unit

let fail_if_minting_revoked (storage : admin_storage) : unit =
  if storage.minting_revoked
  then failwith "MINTING_IS_REVOKED"
  else unit

#else

#if GALLERY_CONTRACT

type admin_entrypoints =
    |   Add_minter of address
    |   Remove_minter of address

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : admin_storage) : unit =
    if Tezos.sender <> storage.admin
    then failwith "NOT_AN_ADMIN"
    else unit

let fail_if_not_minter (add, storage : address * admin_storage) : unit =
    match (Big_map.find_opt add storage.minters ) with
            Some minter -> unit
        |   None -> "NOT_A_MINTER"

let admin_main(param, storage : admin_entrypoints * admin_storage) : (operation list) * admin_storage =
    let () = fail_if_not_admin storage in 
    match param with
        | Add_minter new_minter -> 
            if Big_map.mem new_minter storage.minters
            then (failwith "ALREADY_MINTER" : operation list * admin_storage)            
            else (([] : operation list), { storage with minters = Big_map.add new_minter unit storage.minters })

        | Remove_minter old_minter -> 
            if Big_map.mem old_minter storage.minters
            then ([]: operation list), { storage with minters = Big_map.remove old_minter storage.minters }
            else (failwith "MINTER_NOT_FOUND" : operation list * admin_storage)

#else

type admin_entrypoints =
    |   Pause_minting of bool
    |   Update_minter_manager of address

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : admin_storage) : unit =
    if Tezos.sender <> storage.admin
    then failwith "NOT_AN_ADMIN"
    else unit

let fail_if_minting_paused (storage : admin_storage) : unit =
    if storage.paused_minting
    then failwith "MINTING_PAUSED"
    else unit

let fail_if_not_minter (storage : admin_storage) : unit =
    match ((Tezos.call_view "is_minter" Tezos.sender storage.minters_manager ): bool option) with
        None -> failwith "NOT_A_MINTER"
        | Some is_minter -> 
            if is_minter
            then unit
            else failwith "NOT_A_MINTER"

let admin_main(param, storage : admin_entrypoints * admin_storage) : (operation list) * admin_storage =
    let () = fail_if_not_admin storage in 
    match param with
        | Pause_minting paused ->
            (([]: operation list), { storage with paused_minting = paused; })

        | Update_minter_manager add ->
            (([] : operation list), { storage with minters_manager = add; })
#endif
#endif