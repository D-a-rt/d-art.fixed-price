// -- FA2 editions version originated from Serie factory contract

#include "../../d-art.fa2-editions/compile_fa2_editions_serie.mligo"

let get_fa2_editions_serie_contract (mr: bool) : ( ((editions_entrypoints, editions_storage) typed_address) * address * address * address ) = 
    let () = Test.reset_state 8n ([]: tez list) in
    
    // Admin storage
    let minter = Test.nth_bootstrap_account 7 in

    let admin_str : admin_storage = {
        admin = minter;
        minting_revoked = mr;
    } in

    // Assets storage
    let owner1 = Test.nth_bootstrap_account 1 in
    let owner2 = Test.nth_bootstrap_account 2 in
    let owner3 = Test.nth_bootstrap_account 3 in
    
    let operator1 = Test.nth_bootstrap_account 4 in
    
    let ledger = Big_map.literal([
        (1n, owner1);
        (2n, owner2);
        (3n, owner3);
        (4n, owner1);
    ]) in

    let operators = Big_map.literal([
        ((owner1, (operator1, 1n)), ());
        ((owner2, (operator1, 2n)), ());
        ((owner3, (operator1, 3n)), ());
        ((owner1, (operator1, 4n)), ());
    ]) in

    let asset_str = {
        ledger = ledger;
        operators = operators;
        token_metadata = (Big_map.empty : (token_id, token_metadata) big_map);
    } in

    // Editions storage
    let edition1 = ({
        edition_info = (Map.empty : (string, bytes) map);
        total_edition_number = 5n;
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : split )];
    } : edition_metadata) in

    let editions_metadata = Big_map.literal([
        (0n, edition1);
    ]) in

    // Contract storage
    let str = {
        next_edition_id = 0n;
        max_editions_per_run = 50n ;
        editions_metadata = editions_metadata;
        assets = asset_str;
        admin = admin_str;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate editions_main str 0tez in
    taddr, minter, owner1, minter