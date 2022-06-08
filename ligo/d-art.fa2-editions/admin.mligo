type admin_entrypoints =
    |   PauseMinting of bool
    |   PauseNumberedEditionMinting of bool
    |   AddMinter of address
    |   RemoveMinter of address

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : admin_storage) : unit =
  if Tezos.sender <> storage.admin
  then failwith "NOT_AN_ADMIN"
  else unit

let fail_if_minting_paused (storage : admin_storage) : unit =
  if storage.paused_minting
  then failwith "MINTING_PAUSED"
  else unit

let fail_if_nb_edition_minting_paused (storage : admin_storage) : unit =
  if storage.paused_nb_edition_minting
  then failwith "NUMBERED_EDITION_MINTING_PAUSED"
  else unit

let fail_if_not_minter (storage : admin_storage) : unit =
  if Big_map.mem Tezos.sender storage.minters
  then unit
  else failwith "NOT_A_MINTER"

let admin_main(param, storage : admin_entrypoints * admin_storage) : (operation list) * admin_storage =
    let () = fail_if_not_admin storage in 
    match param with
        | PauseNumberedEditionMinting paused ->
            (([]: operation list), { storage with paused_nb_edition_minting = paused; })

        | PauseMinting paused ->
            (([]: operation list), { storage with paused_minting = paused; })

        | AddMinter new_minter ->
            if Big_map.mem new_minter storage.minters
            then (failwith "ALREADY_MINTER" : operation list * admin_storage)
            else ([]: operation list), { storage with minters = Big_map.add new_minter unit storage.minters}

        | RemoveMinter old_minter_addess ->
            if Big_map.mem old_minter_addess storage.minters
            then ([]: operation list), { storage with minters = Big_map.remove old_minter_addess storage.minters }
            else (failwith "MINTER_NOT_FOUND" : operation list * admin_storage)
