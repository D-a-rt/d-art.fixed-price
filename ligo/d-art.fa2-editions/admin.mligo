#if WILL_ORIGINATE_FROM_FACTORY

type revoke_minting_param =
[@layout:comb]
{
  revoke: bool
}

type admin_entrypoints =
    |   Revoke_minting of revoke_minting_param

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : admin_storage) : unit =
  if Tezos.sender <> storage.admin
  then failwith "NOT_AN_ADMIN"
  else unit

let fail_if_minting_revoked (storage : admin_storage) : unit =
  if storage.minting_revoked
  then failwith "CONTRACT_KILLED_UNABLE_TO_MINT"
  else unit

let admin_main(param, storage : admin_entrypoints * admin_storage) : (operation list) * admin_storage =
    let () = fail_if_not_admin storage in 
    let () : unit = assert_msg ( storage.minting_revoked <> true , "MINTING_IS_REVOKED" ) in
    match param with
        | Revoke_minting param ->
            (([]: operation list), { storage with minting_revoked = param.revoke; })

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
