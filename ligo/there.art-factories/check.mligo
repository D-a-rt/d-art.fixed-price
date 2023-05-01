[@inline]
let assert_msg (condition, msg : bool * string ) : unit = if (not condition) then failwith(msg) else unit

#if SPACE_CONTRACT

(* Fails if sender is not space *)
let fail_if_not_space_manager (storage : storage) : unit =
  match ((Tezos.call_view "is_space_manager" (Tezos.get_sender()) storage.permission_manager ): bool option) with
      None -> failwith "NOT_A_SPACE_MANAGER"
      | Some is_space_manager -> 
        if is_space_manager
        then unit
        else failwith "NOT_A_SPACE_MANAGER"

(* Fails if space already originated contract *)
let fail_if_already_originated (storage : storage) : unit =
    if Big_map.mem (Tezos.get_sender()) storage.spaces
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
  match ((Tezos.call_view "is_admin" (Tezos.get_sender()) storage.permission_manager ): bool option) with
    None -> failwith "NOT_AN_ADMIN"
    | Some is_minter -> 
      if is_minter
      then unit
      else failwith "NOT_AN_ADMIN"
