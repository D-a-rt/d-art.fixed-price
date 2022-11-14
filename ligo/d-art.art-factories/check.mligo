[@inline]
let assert_msg (condition, msg : bool * string ) : unit = if (not condition) then failwith(msg) else unit

#if GALLERY_CONTRACT

(* Fails if sender is not gallery *)
let fail_if_not_gallery (storage : storage) : unit =
  match ((Tezos.call_view "is_gallery" (Tezos.get_sender()) storage.permission_manager ): bool option) with
      None -> failwith "NOT_A_GALLERY"
      | Some is_gallery -> 
        if is_gallery
        then unit
        else failwith "NOT_A_GALLERY"

(* Fails if gallery already originated contract *)
let fail_if_already_originated (storage : storage) : unit =
    if Big_map.mem (Tezos.get_sender()) storage.galleries
    then failwith "ALREADY_ORIGINATED"
    else unit

#else

(* Fails if sender is not admin *)
let fail_if_not_minter (storage : storage) : unit =
  match ((Tezos.call_view "is_minter" (Tezos.get_sender()) storage.permission_manager ): bool option) with
      None -> failwith "NOT_A_MINTER"
      | Some is_minter -> 
        if is_minter
        then unit
        else failwith "NOT_A_MINTER"

#endif
(* Fails if sender is not admin *)
let fail_if_not_admin (storage : storage) : unit =
  if Map.mem (Tezos.get_sender()) storage.admins
  then failwith "NOT_AN_ADMIN"
  else unit
