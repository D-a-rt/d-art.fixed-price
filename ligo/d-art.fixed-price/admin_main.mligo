
type admin_entrypoints =
    | UpdateFee of fee_data
    | UpdatePublicKey of key
    | AddDropSeller of address
    | RemoveDropSeller of address
    | ContractWillUpdate of bool

let is_drop_seller (seller, storage : address * storage) : bool =
  Big_map.mem seller storage.authorized_drops_seller

let admin_main (param, storage : admin_entrypoints * storage) : (operation list) * storage =
  let () = fail_if_not_admin (storage.admin) in
  match param with
    UpdateFee new_fee_data ->
      let () = assert_msg (new_fee_data.percent > 0n || new_fee_data.percent < 100n, "Percentage must be between 0 and 100") in
      ([] : operation list), { storage with fee = new_fee_data }

    | UpdatePublicKey key ->
      ([] : operation list), { storage with admin.pb_key = key; }

    | AddDropSeller seller ->
      if is_drop_seller(seller, storage)
      then (failwith "ALREADY_SELLER" : operation list * storage )
      else ([] : operation list), { storage with authorized_drops_seller = Big_map.add (seller : address) unit storage.authorized_drops_seller }

    | RemoveDropSeller seller ->
      if is_drop_seller(seller, storage)
      then ([] : operation list), { storage with authorized_drops_seller = Big_map.remove (seller : address) storage.authorized_drops_seller }
      else (failwith "SELLER_NOT_FOUND" : operation list * storage )

    | ContractWillUpdate bool -> ([] : operation list), { storage with admin.contract_will_update = bool }
