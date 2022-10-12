#if !WILL_ORIGINATE_FROM_FACTORY
#define WILL_ORIGINATE_FROM_FACTORY

#include "../d-art.fa2-editions/interface.mligo"

#include "interface.mligo"
#include "check.mligo"

type lambda_create_contract = (key_hash option * tez * editions_storage) -> (operation * address) 

type art_factory = 
    |   Create_serie of create_entrypoint
    |   Create_gallery of create_entrypoint
    |   Update_permission_manager of update_manager_entrypoint

let create_serie (param, storage : create_entrypoint * storage) : (operation list) * storage =
    let editions_metadata_str = (Big_map.empty : (nat, edition_metadata) big_map) in
    
    let asset_str = {
        ledger = (Big_map.empty : (token_id, address) big_map);
        operators = (Big_map.empty : ((address * (address * token_id)), unit) big_map);
        token_metadata = (Big_map.empty : (token_id, token_metadata) big_map);
    } in
    
    let admin_str : admin_storage = {
        admin = Tezos.sender;
        minting_revoked = false;
    } in

    let initial_str = {
        next_edition_id = 0n;
        max_editions_per_run = 50n;
        editions_metadata = editions_metadata_str;
        assets = asset_str;
        admin = admin_str;
        metadata = Big_map.literal([("", param.metadata);]);
    } in
    
    let create_contract : lambda_create_contract =
      [%Michelson ( {| { 
            UNPAIR ;
            UNPAIR ;
            CREATE_CONTRACT #include "compile/serie.tz" ;
            PAIR } |}
              : lambda_create_contract)]
    in

    let origination : operation * address = create_contract ((None: key_hash option), 0tez, initial_str) in
    
    let new_serie : serie = { address = origination.1; minter = Tezos.sender; } in
    let new_str = { storage with series = Big_map.add storage.next_serie_id new_serie storage.series; next_serie_id = storage.next_serie_id + 1n } in

    [origination.0], new_str

let create_gallery (param, storage : create_entrypoint * storage) : (operation list) * storage = 
    let editions_metadata_str = (Big_map.empty : (nat, edition_metadata) big_map) in
    
    let asset_str = {
        ledger = (Big_map.empty : (token_id, address) big_map);
        operators = (Big_map.empty : ((address * (address * token_id)), unit) big_map);
        token_metadata = (Big_map.empty : (token_id, token_metadata) big_map);
    } in
    
    let admin_str : admin_storage = {
        admin = Tezos.sender;
        minters = (Big_map.empty : (address, unit) big_map);
    } in

    let initial_str = {
        next_edition_id = 0n;
        max_editions_per_run = 50n;
        editions_metadata = editions_metadata_str;
        assets = asset_str;
        admin = admin_str;
        metadata = Big_map.literal([("", param.metadata);]);
    } in

    let create_contract : lambda_create_contract =
      [%Michelson ( {| { 
            UNPAIR ;
            UNPAIR ;
            CREATE_CONTRACT #include "compile/gallery.tz" ;
            PAIR } |}
              : lambda_create_contract)]
    in

    let origination : operation * address = create_contract ((None: key_hash option), 0tez, initial_str) in
    let new_str = { storage with series = Big_map.add Tezos.sender origination.1 storage.galleries; } in

    [origination.0], new_str


let art_factory_main (param, storage : art_factory * storage)  : (operation list) * storage = 
    let () : unit = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    match param with
        |   Create_serie create_param ->
                let () : unit = fail_if_not_minter storage in
                let () : unit = fail_if_origination_paused storage in
                create_serie (create_param, storage)

        |   Create_gallery create_param ->
                let () : unit = fail_if_not_gallery storage in 
                let () : unit = fail_if_already_originated storage in
                create_gallery (create_param, storage)

        |   Update_permission_manager update_manager_param ->
                let () = fail_if_not_admin storage in 
                (([] : operation list), { storage with permission_manager = update_manager_param.new_manager; })

#endif