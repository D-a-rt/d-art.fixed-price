#include "interface.mligo"
#include "operator_lib.mligo"
#include "standard.mligo"
#include "common.mligo"

#include "admin.mligo"


#if GALLERY_CONTRACT

type pre_mint_edition_param =
[@layout:comb]
{
    minter: address;
    edition_info : bytes;
    total_edition_number : nat;
    royalty: nat;
    splits: split list;
    gallery_comission: nat;
    gallery_comission_splits: split list;
}

type proposal_param = 
[@layout:comb]
{
    proposal_id: nat
}

type editions_entrypoints =
    |   Admin of admin_entrypoints
    |   FA2 of fa2_entry_points
    |   Create_proposals of pre_mint_edition_param list
    |   Remove_proposals of proposal_param list
    |   Mint_editions of proposal_param list
    |   Update_metadata of bytes
    |   Burn_token of burn_param

#else

type mint_edition_param =
[@layout:comb]
{
  edition_info : bytes;
  total_edition_number : nat;
  royalty: nat;
  splits: split list;
}

#if WILL_ORIGINATE_FROM_FACTORY

type editions_entrypoints =
    |   Revoke_minting of revoke_minting_param
    |   FA2 of fa2_entry_points
    |   Mint_editions of mint_edition_param list
    |   Update_metadata of bytes
    |   Burn_token of burn_param

#else 

type editions_entrypoints =
    |   Admin of admin_entrypoints
    |   FA2 of fa2_entry_points
    |   Mint_editions of mint_edition_param list
    |   Update_metadata of bytes
    |   Burn_token of burn_param

#endif
#endif

let fail_if_not_owner (sender, token_id, storage : address * token_id * editions_storage) : unit =
    match (Big_map.find_opt token_id storage.assets.ledger) with
    | None -> (failwith "FA2_TOKEN_UNDEFINED"  : unit)
    | Some cur_o ->
      if cur_o = sender
      then unit
      else (failwith "FA2_INSUFFICIENT_BALANCE" : unit)


let rec recurs_add (address, acc, len : address * (address list) * nat) : (address list) =
    if len > 0n
    then let l = address :: acc in recurs_add (address, l, abs (len - 1n))
    else acc

let mint_edition_to_addresses ( edition_id, receiver, edition_metadata, storage : edition_id * address * edition_metadata * editions_storage) : editions_storage =
    
    let mint_edition_to_address : (((assign_edition_param list) * token_id) * address) -> ((assign_edition_param list) * token_id) =
        fun ( (assign_edition_param_l, token_id), address : ((assign_edition_param list) * token_id) * address) ->
            let new_assigned_edition : assign_edition_param = ({
                token_id = token_id;
                owner = address;
            } : assign_edition_param) in
            ((new_assigned_edition :: assign_edition_param_l) , token_id + 1n)
    in

    let initial_token_id : nat = (edition_id * storage.max_editions_per_run) in
    let receiver_list = recurs_add (receiver, ([] : address list), edition_metadata.total_edition_number) in
    let create_editions_param, _ : (assign_edition_param list) * token_id = (List.fold mint_edition_to_address receiver_list (([] : (assign_edition_param list)), initial_token_id)) in
    let _ , nft_token_storage = mint_edition_set (create_editions_param, storage.assets) in
    
    let new_storage = {storage with assets = nft_token_storage } in
    new_storage

let verify_split (c, spt : nat * split) : nat = c + spt.pct

#if WILL_ORIGINATE_FROM_FACTORY

let mint_editions ( edition_run_list , storage : mint_edition_param list * editions_storage) : operation list * editions_storage =

    let mint_single_edition_run : (editions_storage * mint_edition_param) -> editions_storage =
        fun (storage, param : editions_storage * mint_edition_param) ->
            let () : unit = assert_msg(param.royalty <= 250n, "ROYALTIES_CANNOT_EXCEED_25_PERCENT") in
            let () : unit = assert_msg(param.total_edition_number >= 1n, "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") in
            let () : unit = assert_msg(param.total_edition_number <= storage.max_editions_per_run, "EDITION_RUN_TOO_LARGE" ) in

            let split_count : nat = List.fold_left verify_split 0n param.splits  in
            let () : unit = assert_msg (split_count = 1000n, "TOTAL_SPLIT_MUST_BE_100_PERCENT") in
            
            let edition_metadata : edition_metadata = {
                edition_info = Map.literal [("", param.edition_info)];
                royalty = param.royalty;
                splits = param.splits;
                total_edition_number = param.total_edition_number;
            } in
            
            let edition_storage = { storage with
                next_edition_id = storage.next_edition_id + 1n;
                editions_metadata = Big_map.add storage.next_edition_id edition_metadata storage.editions_metadata;
            } in

            mint_edition_to_addresses (storage.next_edition_id, Tezos.sender, edition_metadata, edition_storage)
        in
    ([] : operation list), List.fold mint_single_edition_run edition_run_list storage

let editions_main (param, editions_storage : editions_entrypoints * editions_storage) : (operation  list) * editions_storage =
    let () : unit = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    match param with
        | Revoke_minting revoke_param ->
            let () = fail_if_not_admin editions_storage.admin in 
            let () = fail_if_minting_revoked editions_storage.admin in
            (([]: operation list), { editions_storage with admin.minting_revoked = revoke_param.revoke; })

        | FA2 fa2_entry_points ->
            let ops, new_storage = fa2_main (fa2_entry_points, editions_storage.assets) in
            ops, { editions_storage with assets = new_storage } 

        | Mint_editions mint_param ->
            let () = fail_if_not_admin editions_storage.admin in
            let () = fail_if_minting_revoked editions_storage.admin in
            mint_editions (mint_param, editions_storage)

        | Update_metadata metadata_param -> 
            let () = fail_if_not_admin editions_storage.admin in
            let res = match Big_map.find_opt "" editions_storage.metadata with
                |   Some _ -> ([]: operation list), {editions_storage with metadata = Big_map.update ("") (Some metadata_param) editions_storage.metadata }
                |   None -> ([]: operation list), {editions_storage with metadata = Big_map.add ("") metadata_param editions_storage.metadata }
            in
            res

        | Burn_token burn_param ->
            let () = assert_msg (burn_param.owner = Tezos.sender, "NOT_OWNER") in
            let () : unit = fail_if_not_owner (Tezos.sender, burn_param.token_id, editions_storage) in
            ([]: operation list), { editions_storage with assets.ledger =  Big_map.remove burn_param.token_id editions_storage.assets.ledger }

#else

#if GALLERY_CONTRACT

let create_proposal (edition_run_list , storage : pre_mint_edition_param list * editions_storage) : operation list * editions_storage =
    let create_single_proposal : (editions_storage * pre_mint_edition_param) -> editions_storage =
        fun (storage, param : editions_storage * pre_mint_edition_param) ->

            let () : unit = assert_msg(param.royalty <= 250n, "ROYALTIES_CANNOT_EXCEED_25_PERCENT") in
            let () : unit = assert_msg(param.gallery_comission <= 500n, "COMISSIONS_CANNOT_EXCEED_50_PERCENT") in
            let () : unit = assert_msg(param.royalty >= 50n, "ROYALTIES_MINIMUM_5_PERCENT") in
            let () : unit = assert_msg(param.total_edition_number >= 1n, "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") in
            let () : unit = assert_msg(param.total_edition_number <= storage.max_editions_per_run, "EDITION_RUN_TOO_LARGE" ) in
            let () : unit = fail_if_not_minter (param.minter, storage.admin) in

            let split_count : nat = List.fold_left verify_split 0n param.splits  in
            let () : unit = assert_msg (split_count = 1000n, "TOTAL_SPLIT_MUST_BE_100_PERCENT") in

            let commission_count : nat = List.fold_left verify_split 0n param.gallery_comission_splits  in
            let () : unit = assert_msg (commission_count = 1000n, "TOTAL_COMISSION_SPLIT_MUST_BE_100_PERCENT") in
            
            let edition_metadata : edition_metadata = {
                minter = param.minter;
                edition_info = Map.literal [("", param.edition_info)];
                royalty = param.royalty;
                splits = param.splits;
                gallery_comission = param.gallery_comission;
                gallery_comission_splits = param.gallery_comission_splits;
                total_edition_number = param.total_edition_number;
            } in
            
        { storage with next_edition_id = storage.next_edition_id + 1n; mint_proposals = Big_map.add storage.next_edition_id edition_metadata storage.mint_proposals; }
    in

    ([] : operation list), List.fold create_single_proposal edition_run_list storage

let remove_proposals (remove_list, storage : proposal_param list * editions_storage ) : operation list * editions_storage =
    let remove_single_proposal : (editions_storage * proposal_param) -> editions_storage =
        fun (storage, param : editions_storage * proposal_param) -> { storage with mint_proposals = Big_map.remove param.proposal_id storage.mint_proposals }
    in

    let new_storage = List.fold remove_single_proposal remove_list storage in
    ([] : operation list), new_storage

let mint_editions (edition_run_list, storage : proposal_param list * editions_storage) : operation list * editions_storage =
    let mint_single_edition_run : (editions_storage * proposal_param) -> editions_storage = 
        fun (storage, param : editions_storage * proposal_param) ->
            
            match Big_map.find_opt param.proposal_id storage.mint_proposals with
                |   None -> (failwith "FA2_PROPOSAL_UNDEFINED"  : editions_storage)
                |   Some proposal -> (
                    let () = assert_msg (proposal.minter = Tezos.sender, "MINTER_MUST_BE_SENDER") in
                    let edition_storage = { storage with 
                        editions_metadata = Big_map.add param.proposal_id proposal storage.editions_metadata;
                        mint_proposals = Big_map.remove param.proposal_id storage.mint_proposals;
                    } in
                    mint_edition_to_addresses (param.proposal_id, storage.admin.admin, proposal, edition_storage)
                )
    in
    ([]: operation list), List.fold mint_single_edition_run edition_run_list storage

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

        | Create_proposals create_param ->
            let () = fail_if_not_admin editions_storage.admin in
            create_proposal (create_param, editions_storage)

        | Remove_proposals remove_param ->
            let () = fail_if_not_admin editions_storage.admin in
            remove_proposals (remove_param, editions_storage)

        | Mint_editions mint_param -> 
            let () = fail_if_not_minter (Tezos.sender, editions_storage.admin) in
            mint_editions (mint_param, editions_storage)

        | Update_metadata metadata_param -> 
            let () = fail_if_not_admin editions_storage.admin in
            
            let res = match Big_map.find_opt "" editions_storage.metadata with
                |   Some _ -> ([]: operation list), {editions_storage with metadata = Big_map.update ("") (Some metadata_param) editions_storage.metadata }
                |   None -> ([]: operation list), {editions_storage with metadata = Big_map.add ("") metadata_param editions_storage.metadata }
            in
            res

        | Burn_token burn_param ->
            let () = assert_msg (burn_param.owner = Tezos.sender, "NOT_OWNER") in
            let () : unit = fail_if_not_owner (Tezos.sender, burn_param.token_id, editions_storage) in
            ([]: operation list), { editions_storage with assets.ledger =  Big_map.remove burn_param.token_id editions_storage.assets.ledger }

#else

let mint_editions ( edition_run_list , storage : mint_edition_param list * editions_storage) : operation list * editions_storage =

    let mint_single_edition_run : (editions_storage * mint_edition_param) -> editions_storage =
        fun (storage, param : editions_storage * mint_edition_param) ->
        let () : unit = assert_msg(param.royalty <= 250n, "ROYALTIES_CANNOT_EXCEED_25_PERCENT") in
        let () : unit = assert_msg(param.total_edition_number >= 1n, "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") in
        let () : unit = assert_msg(param.total_edition_number <= storage.max_editions_per_run, "EDITION_RUN_TOO_LARGE" ) in

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
        } in

        mint_edition_to_addresses (storage.next_edition_id, Tezos.sender, edition_metadata, edition_storage)
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

        | Update_metadata metadata_param -> 
            let () = fail_if_not_admin editions_storage.admin in
            
            let res = match Big_map.find_opt "" editions_storage.metadata with
                |   Some _ -> ([]: operation list), {editions_storage with metadata = Big_map.update ("") (Some metadata_param) editions_storage.metadata }
                |   None -> ([]: operation list), {editions_storage with metadata = Big_map.add ("") metadata_param editions_storage.metadata }
            in
            res

        | Burn_token burn_param ->
            let () = assert_msg (burn_param.owner = Tezos.sender, "NOT_OWNER") in
            let () : unit = fail_if_not_owner (Tezos.sender, burn_param.token_id, editions_storage) in
            ([]: operation list), { editions_storage with assets.ledger =  Big_map.remove burn_param.token_id editions_storage.assets.ledger }

#endif
#endif