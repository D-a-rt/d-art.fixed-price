
type admin_entrypoints =
    | UpdatePublicKey of key
    | AddDropSeller of seller
    | RemoveDropSeller of seller

let is_drop_seller (seller, storage : seller * storage) : bool =
  Big_map.mem seller storage.authorized_drops_seller

let admin_main (param, storage : admin_entrypoints * storage) : (operation list) * storage = match param with

  | UpdatePublicKey key -> 
    let fail = fail_if_not_admin (storage.admin) in
    let new_admin_storage : admin_storage = {
      admin_address = storage.admin.admin_address;
      pb_key = key;
      signed_message_used = storage.admin.signed_message_used;
    } in
    let new_storage = { storage with admin = new_admin_storage } in
    ([] : operation list), new_storage

  | AddDropSeller seller -> 
    let fail = fail_if_not_admin (storage.admin) in
    
    if is_drop_seller(seller, storage)
    then ([] : operation list), { storage with authorized_drops_seller = Big_map.add (seller : seller) unit storage.authorized_drops_seller }
    else (failwith "SELLER_ALREADY_ADDED" : operation list * storage )

  | RemoveDropSeller seller ->
    let fail = fail_if_not_admin (storage.admin) in
    
    if is_drop_seller(seller, storage)
    then ([] : operation list), { storage with authorized_drops_seller = Big_map.remove (seller : seller) storage.authorized_drops_seller }
    else (failwith "SELLER_NOT_FOUND" : operation list * storage )
