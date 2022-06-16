#import "../../d-art.fa2-editions/interface.mligo" "FA2_I"
#import "../../d-art.fa2-editions/multi_nft_token_editions.mligo" "FA2_E"

// Create initial storage
let get_initial_storage (pm, pnbm : bool * bool) : ( ((FA2_E.editions_entrypoints, FA2_I.editions_storage) typed_address) * address * address * address ) = 
    let () = Test.reset_state 8n ([]: tez list) in

    // Admin storage
    let admin = Test.nth_bootstrap_account 0 in
 
    let minter = Test.nth_bootstrap_account 7 in

    let admin_str : FA2_I.admin_storage = {
        admin = admin;
        paused_minting = pm;
        paused_nb_edition_minting = pnbm;
        minters = Big_map.literal([
            (minter), ();
        ])
    } in

    // Assets storage
    let owner1 = Test.nth_bootstrap_account 1 in
    let owner2 = Test.nth_bootstrap_account 2 in
    let owner3 = Test.nth_bootstrap_account 3 in
    
    let operator1 = Test.nth_bootstrap_account 4 in
    let operator2 = Test.nth_bootstrap_account 5 in
    let operator3 = Test.nth_bootstrap_account 6 in
    
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

    let edition_info = (Map.empty : (string, bytes) map) in
    let token_metadata = (Big_map.empty : (FA2_I.token_id, FA2_I.token_metadata) big_map) in
    
    let asset_str = {
        ledger = ledger;
        operators = operators;
        token_metadata = token_metadata;
    } in

    // Editions storage
    let edition1 = ({
        minter = minter;
        edition_info = (Map.empty : (string, bytes) map);
        total_edition_number = 5n;
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )];
    } : FA2_I.edition_metadata) in

    let editions_metadata = Big_map.literal([
        (0n, edition1);
    ]) in

    // Contract storage
    let str = {
        next_edition_id = 1n;
        max_editions_per_run = 250n ;
        editions_metadata = editions_metadata;
        assets = asset_str;
        admin = admin_str;
        metadata = (Big_map.empty : (string, bytes) big_map);
        hash_used = (Big_map.empty : (bytes, unit) big_map);
    } in

    let taddr, _, _ = Test.originate FA2_E.editions_main str 0tez in
    taddr, admin, owner1, minter
