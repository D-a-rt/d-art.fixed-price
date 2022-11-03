
#import "../d-art.permission-manager/storage.test.mligo" "PM_S"
#import "../../d-art.fa2-editions/views.mligo" "FA2_E"

// Create initial storage
let get_fa2_editions_contract (pm : bool) : ( ((FA2_E.editions_entrypoints, FA2_E.editions_storage) typed_address) * address * address * address ) = 
    let () = Test.reset_state 8n ([]: tez list) in
    
    // Admin storage
    let admin = Test.nth_bootstrap_account 0 in
 
    let minter = Test.nth_bootstrap_account 7 in
    let _, pm_contract_addr = PM_S.get_permission_manager_contract (Some (minter)) in

    let admin_str : FA2_E.admin_storage = {
        admin = admin;
        paused_minting = pm;
        minters_manager = pm_contract_addr;
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

    let token_metadata = (Big_map.empty : (FA2_E.token_id, FA2_E.token_metadata) big_map) in
    
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
        } : FA2_E.split )];
    } : FA2_E.edition_metadata) in

    let editions_metadata = Big_map.literal([
        (0n, edition1);
    ]) in

    // Contract storage
    let str = {
        next_token_id = 0n;
        max_editions_per_run = 50n;
        as_minted = (Big_map.empty : (address, unit) big_map); 
        editions_metadata = editions_metadata;
        assets = asset_str;
        admin = admin_str;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate FA2_E.editions_main str 0tez in
    taddr, admin, owner1, minter
