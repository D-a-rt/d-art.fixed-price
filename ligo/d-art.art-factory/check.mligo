[@inline]
let assert_msg (condition, msg : bool * string ) : unit = if (not condition) then failwith(msg) else unit

(* Fails if sender is not admin *)
let fail_if_not_minter (storage : storage) : unit =
  match ((Tezos.call_view "is_minter" Tezos.sender storage.permission_manager ): bool option) with
      None -> failwith "NOT_A_MINTER"
      | Some is_minter -> 
        if is_minter
        then unit
        else failwith "NOT_A_MINTER"

(* Fails if sender is not gallery *)
let fail_if_not_gallery (storage : storage) : unit =
  match ((Tezos.call_view "is_gallery" Tezos.sender storage.permission_manager ): bool option) with
      None -> failwith "NOT_A_GALLERY"
      | Some is_gallery -> 
        if is_gallery
        then unit
        else failwith "NOT_A_GALLERY"

(* Fails if gallery already originated contract *)
let fail_if_already_originated (storage : storage) : unit =
    if Big_map.mem Tezos.sender storage.galleries
    then failwith "ALREADY_ORIGINATED"
    else unit

(* Fails if serie origination paused *)
let fail_if_origination_paused (storage : storage) : unit =
  match ((Tezos.call_view "is_serie_origination_paused" unit storage.permission_manager ): bool option) with
      None -> failwith "CREATION_OF_SERIES_PAUSED"
      | Some is_serie_origination_paused -> 
        if is_serie_origination_paused
        then failwith "CREATION_OF_SERIES_PAUSED"
        else unit

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : storage) : unit =
  if Tezos.sender <> storage.admin
  then failwith "NOT_AN_ADMIN"
  else unit
