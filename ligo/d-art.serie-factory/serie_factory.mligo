#if !WILL_ORIGINATE_FROM_FACTORY
#define WILL_ORIGINATE_FROM_FACTORY

#include "../d-art.fa2-editions/interface.mligo"

#include "interface.mligo"
#include "admin.mligo"

[@inline]
let assert_msg (condition, msg : bool * string ) : unit = if (not condition) then failwith(msg) else unit

type lambda_create_contract = (key_hash option * tez * editions_storage) -> (operation * address) 

type art_serie_factory = 
    |   Admin of admin_factory_entrypoints
    |   Create_serie of create_serie_entrypoint
    |   Accept_admin_invitation of admin_response_param 

let fail_if_not_minter (storage : serie_factory_storage) : unit =
  if Big_map.mem Tezos.sender storage.minters
  then unit
  else failwith "NOT_A_MINTER"

let create_serie (param, storage : create_serie_entrypoint * serie_factory_storage) : (operation list) * serie_factory_storage =
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
        next_edition_id = 1n;
        max_editions_per_run = 250n ;
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
#include "compile/serie.tz"
               ;
            PAIR } |}
              : lambda_create_contract)]
    in

    let origination : operation * address = create_contract ((None: key_hash option), 0tez, initial_str) in
    let new_serie : serie = {
        address = origination.1;
        minter = Tezos.sender;
    } in

    let new_str = { storage with series = Big_map.add storage.next_serie_id new_serie storage.series; next_serie_id = storage.next_serie_id + 1n } in

    [origination.0], new_str

let art_serie_factory_main (param, storage : art_serie_factory * serie_factory_storage)  : (operation list) * serie_factory_storage = 
    let () : unit = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    match param with
        |   Admin a ->
                admin_main (a, storage)

        |   Create_serie create_param ->
                let () : unit = fail_if_not_minter (storage) in
                let () : unit = assert_msg (storage.origination_paused <> true, "CREATION_OF_SERIES_PAUSED") in
                create_serie (create_param, storage)

        |   Accept_admin_invitation param ->
                let () : unit = fail_if_sender_not_pending_admin (storage) in
                if param.accept = true
                then ([] : operation list), { storage with admin.pending_admin = (None : address option); admin.admin = Tezos.sender }
                else ([] : operation list), { storage with admin.pending_admin = (None : address option) }

#endif