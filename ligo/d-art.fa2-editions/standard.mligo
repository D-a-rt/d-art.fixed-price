type fa2_entry_points =
  | Transfer of transfer list
  | Balance_of of balance_of_param
  | Update_operators of update_operator list

let transfers_to_descriptors (txs : transfer list) : transfer_descriptor list =
    List.map
        (fun (tx : transfer) ->
        let txs = List.map
            (fun (dst : transfer_destination) ->
            {
                to_ = Some dst.to_;
                token_id = dst.token_id;
                amount = dst.amount;
            }
            ) tx.txs in
            {
                from_ = Some tx.from_;
                txs = txs;
            }
        ) txs

let dec_balance(owner, token_id, ledger : address option * token_id * ledger) : ledger =
    match owner with
        None -> ledger (* this is mint transfer, don't change the ledger *)
    |   Some o -> (
            let current_owner = Big_map.find_opt token_id ledger in
            match current_owner with
                    Some cur_o ->   if cur_o = o
                                    then Big_map.remove token_id ledger
                                    else (failwith "FA2_INSUFFICIENT_BALANCE" : ledger)
                |   None -> (failwith "FA2_TOKEN_UNDEFINED" : ledger)
            
    )

    let inc_balance(owner, token_id, ledger : address option * token_id * ledger) : ledger =
    match owner with
            Some o -> Big_map.add token_id o ledger
        |   None -> ledger (* this is burn transfer, don't change the ledger *)

let transfer (txs, validate_op, ops_storage, ledger : (transfer_descriptor list) * operator_validator * operator_storage * ledger) : ledger =
    let make_transfer = fun (l, tx : ledger * transfer_descriptor) ->
        List.fold
        (fun (ll, dst : ledger * transfer_destination_descriptor) ->
            let () = match tx.from_ with
            | None -> unit
            | Some owner -> validate_op (owner, Tezos.sender, dst.token_id, ops_storage)
            in
            if dst.amount > 1n
            then (failwith "FA2_INSUFFICIENT_BALANCE" : ledger)
            else if dst.amount = 0n
            then match Big_map.find_opt dst.token_id ll with
                | None -> (failwith "FA2_TOKEN_UNDEFINED"  : ledger)
                | Some _cur_o -> ll (* zero transfer, don't change the ledger *)
            else
            let lll = dec_balance (tx.from_, dst.token_id, ll) in
            inc_balance(dst.to_, dst.token_id, lll)
        ) tx.txs l
    in
    List.fold make_transfer txs ledger

let fa2_transfer (tx_descriptors, validate_op, storage : (transfer_descriptor list) * operator_validator * nft_token_storage) : (operation list) * nft_token_storage =

    let new_ledger = transfer (tx_descriptors, validate_op, storage.operators, storage.ledger) in
    let new_storage = { storage with ledger = new_ledger; } in
    ([]: operation list), new_storage

let get_balance (p, ledger : balance_of_param * ledger) : operation =
    let to_balance = fun (r : balance_of_request) ->
        let owner = Big_map.find_opt r.token_id ledger in
        match owner with
                Some o -> (
                    let bal = if o = r.owner then 1n else 0n in
                    { request = r; balance = bal; }
                )
            |    None -> (failwith "FA2_TOKEN_UNDEFINED"  : balance_of_response)
    in
let responses = List.map to_balance p.requests in
Tezos.transaction responses 0mutez p.callback

(**
Update ledger balances according to the specified transfers. Fails if any of the
permissions or constraints are violated.
@param txs transfers to be applied to the ledger
@param validate_op function that validates of the tokens from the particular owner can be transferred.
*)

let fa2_update_operators (updates, storage
    : (update_operator list) * operator_storage) : operator_storage =
  let updater = Tezos.sender in
  let process_update = (fun (ops, update : operator_storage * update_operator) ->
    let () = validate_update_operators_by_owner (update, updater) in
    update_operators (update, ops)
  ) in
  List.fold process_update updates storage


let fa2_main (param, storage : fa2_entry_points * nft_token_storage) : (operation  list) * nft_token_storage =
    match param with
        | Transfer txs ->
            let tx_descriptors = transfers_to_descriptors txs in
            fa2_transfer (tx_descriptors, default_operator_validator, storage)

        | Balance_of p ->
            let op = get_balance (p, storage.ledger) in
            [op], storage

        | Update_operators updates ->
            let new_operators = fa2_update_operators (updates, storage.operators) in
            let new_storage = { storage with operators = new_operators; } in
            ([] : operation list), new_storage
