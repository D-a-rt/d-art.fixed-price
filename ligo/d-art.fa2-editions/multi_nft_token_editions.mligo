#include "interface.mligo"
#include "operator_lib.mligo"
#include "standard.mligo"
#include "common.mligo"

#include "admin.mligo"

type mint_edition_param =
[@layout:comb]
{
  edition_info : bytes;
  total_edition_number : nat;
  royalty: nat;
  splits: split list;
  receivers : address list;
}

type editions_entrypoints =
    |   Admin of admin_entrypoints
    |   FA2 of fa2_entry_points
    |   Mint_editions of mint_edition_param list
    |   Burn_token of burn_param

let fail_if_not_owner (sender, token_id, storage : address * token_id * editions_storage) : unit =
    match (Big_map.find_opt token_id storage.assets.ledger) with
    | None -> (failwith "FA2_TOKEN_UNDEFINED"  : unit)
    | Some cur_o ->
      if cur_o = sender
      then unit
      else (failwith "FA2_INSUFFICIENT_BALANCE" : unit)

let rec recurs_add (len, receivers : nat * (address list)) : (address list) =
    if len > 0n
    then let l = Tezos.sender :: receivers in recurs_add (abs (len - 1n), l)
    else receivers

let rec rev_l (acc, l : (address list) * (address list)) : (address list) =
    match l with
        | [] -> acc
        | h::t -> rev_l (h::acc, t)

let add_a (l, add : (address list) * address) : (address list) = add::l

let mint_edition_to_addresses ( edition_id, receivers, edition_metadata, storage : edition_id * (address list) * edition_metadata * editions_storage) : editions_storage =
    
    let mint_edition_to_address : (((assign_edition_param list) * token_id) * address) -> ((assign_edition_param list) * token_id) =
        fun ( (assign_edition_param_l, token_id), address : ((assign_edition_param list) * token_id) * address) ->
            let new_assigned_edition : assign_edition_param = ({
                token_id = token_id;
                owner = address;
            } : assign_edition_param) in
            ((new_assigned_edition :: assign_edition_param_l) , token_id + 1n)
    in

    let initial_token_id : nat = (edition_id * storage.max_editions_per_run) in
    
    let to_add = recurs_add (abs (edition_metadata.total_edition_number - List.size receivers), ([] : address list))  in
    let rev_rece = rev_l (([] : address list), receivers) in
    let token_recv = List.fold add_a rev_rece to_add in

    let create_editions_param, _ : (assign_edition_param list) * token_id = (List.fold mint_edition_to_address token_recv (([] : (assign_edition_param list)), initial_token_id)) in
    let _ , nft_token_storage = mint_edition_set (create_editions_param, storage.assets) in
    
    let new_storage = {storage with assets = nft_token_storage } in
    new_storage

let verify_split (c, spt : nat * split) : nat = c + spt.pct

let mint_editions ( edition_run_list , storage : mint_edition_param list * editions_storage) : operation list * editions_storage =

    let mint_single_edition_run : (editions_storage * mint_edition_param) -> editions_storage =
        fun (storage, param : editions_storage * mint_edition_param) ->
        let () : unit = assert_msg(param.royalty <= 250n, "ROYALTIES_CANNOT_EXCEED_25_PERCENT") in
        let () : unit = assert_msg(param.total_edition_number >= 1n, "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") in
        let () : unit = assert_msg(param.total_edition_number <= storage.max_editions_per_run, "EDITION_RUN_TOO_LARGE" ) in
        let () : unit = assert_msg(List.size param.receivers <= param.total_edition_number, "MORE_RECEIVERS_THAN_EDITIONS") in
        let () : unit = if storage.admin.paused_nb_edition_minting then assert_msg (param.total_edition_number = 1n, "MULTIPLE_EDITION_MINTING_CLOSED") in
        let () : unit = assert_msg(not Big_map.mem param.edition_info storage.hash_used, "HASH_ALREADY_USED") in

        let split_count : nat = List.fold_left verify_split 0n param.splits  in
        let () : unit = assert_msg (split_count = 1000n, "TOTAL_SPLIT_MUST_BE_100_PERCENT") in
        
        let edition_metadata : edition_metadata = {
            minter = Tezos.sender;
            edition_info = Map.literal [("", param.edition_info)];
            royalty = param.royalty;
            splits = param.splits;
            total_edition_number = param.total_edition_number;
        } in
        
        let edition_storage = { storage with
            next_edition_id = storage.next_edition_id + 1n;
            editions_metadata = Big_map.add storage.next_edition_id edition_metadata storage.editions_metadata;
            hash_used = Big_map.add param.edition_info unit storage.hash_used;
        } in

        mint_edition_to_addresses (storage.next_edition_id, param.receivers, edition_metadata, edition_storage)
        in

    let new_storage = List.fold mint_single_edition_run edition_run_list storage in
    ([] : operation list), new_storage


let editions_main (param, editions_storage : editions_entrypoints * editions_storage) : (operation  list) * editions_storage =
    let () : unit = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    match param with
        | Admin a ->
            let ops, admin = admin_main (a, editions_storage.admin) in
            let new_storage = { editions_storage with admin = admin; } in
            ops, new_storage

        | FA2 fa2_entry_points ->
            let ops, new_storage = fa2_main (fa2_entry_points, editions_storage.assets) in
            ops, { editions_storage with assets = new_storage } 

        | Mint_editions mint_param ->
            let () = fail_if_minting_paused editions_storage.admin in
            let () = fail_if_not_minter editions_storage.admin in
            mint_editions (mint_param, editions_storage)

        | Burn_token burn_param ->
            let () = assert_msg (burn_param.owner = Tezos.sender, "NOT_OWNER") in
            let () : unit = fail_if_not_owner (Tezos.sender, burn_param.token_id, editions_storage) in
            ([]: operation list), { editions_storage with assets.ledger =  Big_map.remove burn_param.token_id editions_storage.assets.ledger }
