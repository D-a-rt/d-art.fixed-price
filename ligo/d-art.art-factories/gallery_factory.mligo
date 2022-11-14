#if !GALLERY_CONTRACT
#define GALLERY_CONTRACT

#include "../d-art.fa2-editions/interface.mligo"

#include "interface.mligo"
#include "check.mligo"

type lambda_create_contract = (key_hash option * tez * editions_storage) -> (operation * address) 

type art_factory = 
    |   Create_gallery of create_entrypoint
    |   Update_permission_manager of update_manager_entrypoint
    |   Add_admin of address
    |   Remove_admin of address

let create_gallery (param, storage : create_entrypoint * storage) : (operation list) * storage = 
    let editions_metadata_str = (Big_map.empty : (nat, edition_metadata) big_map) in
    
    let asset_str = {
        ledger = (Big_map.empty : (token_id, address) big_map);
        operators = (Big_map.empty : ((address * (address * token_id)), unit) big_map);
        token_metadata = (Big_map.empty : (token_id, token_metadata) big_map);
    } in
    
    let admin_str : admin_storage = {
        admins = Map.literal ([(Tezos.get_sender(), ())]) ;
        minters = (Big_map.empty : (address, unit) big_map);
        pending_minters = (Big_map.empty : (address, unit) big_map);
    } in

    let initial_str = {
        next_edition_id = 0n;
        max_editions_per_run = 50n;
        mint_proposals = editions_metadata_str;
        editions_metadata = editions_metadata_str;
        assets = asset_str;
        admin = admin_str;
        metadata = Big_map.literal([("", param.metadata);]);
    } in

    let create_contract : lambda_create_contract =
      [%Michelson ( {| { 
            UNPAIR ;
            UNPAIR ;
            CREATE_CONTRACT 
#include "compile/gallery.tz"
               ;
            PAIR } |}
              : lambda_create_contract)]
    in

    let origination : operation * address = create_contract ((None: key_hash option), 0tez, initial_str) in
    let new_str = { storage with galleries = Big_map.add (Tezos.get_sender()) origination.1 storage.galleries; } in

    [origination.0], new_str


let gallery_factory_main (param, storage : art_factory * storage)  : (operation list) * storage = 
    let () : unit = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    match param with
        |   Create_gallery create_param ->
                let () : unit = fail_if_not_gallery storage in 
                let () : unit = fail_if_already_originated storage in
                create_gallery (create_param, storage)

        |   Update_permission_manager update_manager_param ->
                let () = fail_if_not_admin storage in 
                (([] : operation list), { storage with permission_manager = update_manager_param.new_manager; })

        |   Add_admin add ->
            let () = fail_if_not_admin storage in
            if Map.mem add storage.admins
            then (failwith "ALREADY_ADMIN" : operation list * admin_storage)
            else ([] : operation list), { storage with admins = Map.add add unit storage.admins; }
        
        |   Remove_admin add ->
            let () = fail_if_not_admin storage in
            if Map.size storage.admins > 1n
            then ([] : operation list), { storage with admins = Map.remove add storage.admins}
            else (failwith "MINIMUM_1_ADMIN" : operation list * admin_storage)


#endif