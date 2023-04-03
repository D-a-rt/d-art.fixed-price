
#import "../there.permission-manager/storage.test.mligo" "PM_S"
#import "../../there.fa2-editions/views.mligo" "FA2_E"

// Create initial storage
let get_fa2_editions_contract (pm : bool) : ( ((FA2_E.editions_entrypoints, FA2_E.editions_storage) typed_address) * address * address * address ) = 
    let () = Test.reset_state 8n ([]: tez list) in
    
    // Admin storage
 
    let minter = Test.nth_bootstrap_account 7 in
    let _, pm_contract_addr = PM_S.get_permission_manager_contract (Some (minter), false) in
    // Admin from permission manager
    let admin = Test.nth_bootstrap_account 0 in

    let admin_str : FA2_E.admin_storage = {
        paused_minting = pm;
        permission_manager = pm_contract_addr;
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
        license = {
            upgradeable = False;
            hash = ("ff7a7aff" : bytes);
        };
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
        next_token_id = 1n;
        max_editions_per_run = 50n;
        as_minted = (Big_map.empty : (address, unit) big_map); 
        proposals = (Big_map.empty : (nat, FA2_E.proposal_metadata) big_map);
        editions_metadata = editions_metadata;
        assets = asset_str;
        admin = admin_str;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate FA2_E.editions_main str 0tez in
    taddr, admin, owner1, minter

let get_edition_fa2_contract_fixed_price (fixed_price_contract : address) = 

    let admin = Test.nth_bootstrap_account 0 in
    let buyer = Test.nth_bootstrap_account 1 in
    let token_seller = Test.nth_bootstrap_account 3 in
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_split = Test.nth_bootstrap_account 5 in

    let _, pm_contract_addr = PM_S.get_permission_manager_contract (Some (token_minter), false) in

    let admin_strg : FA2_E.admin_storage = {
        paused_minting = false;
        permission_manager = pm_contract_addr;
    } in

    let asset_strg : FA2_E.nft_token_storage = {
        ledger = Big_map.literal([
                (0n), (token_seller)        
            ]);
        operators = Big_map.literal([
                ((token_seller, (fixed_price_contract, 0n)), ())  ;      
                ((buyer, (fixed_price_contract, 0n)), ())  ;      
            ]);
        token_metadata = (Big_map.empty : (FA2_E.token_id, FA2_E.token_metadata) big_map);
    } in

    let edition_meta : FA2_E.edition_metadata = ({
            minter = admin;
            edition_info = (Map.empty : (string, bytes) map);
            total_edition_number = 2n;
            license = {
                upgradeable = False;
                hash = ("" : bytes);
            };
            royalty = 150n;
            splits = [({
                address = token_minter;
                pct = 500n;
            } : FA2_E.split );
            ({
                address = token_split;
                pct = 500n;
            } : FA2_E.split )];
        } : FA2_E.edition_metadata ) in

    let edition_meta_strg : FA2_E.editions_metadata = Big_map.literal([
        (0n), (edition_meta);
    ]) in

    let edition_strg = {
        next_token_id = 1n;
        max_editions_per_run = 50n;
        as_minted = (Big_map.empty : (address, unit) big_map);
        proposals = (Big_map.empty : (nat, FA2_E.proposal_metadata) big_map);
        editions_metadata = edition_meta_strg;
        assets = asset_strg;
        admin = admin_strg;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    // Path of the contract on yout local machine
    let michelson_str = Test.compile_value edition_strg in
    let edition_addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.fa2-editions/compile_fa2_editions.mligo" "editions_main" ([] : string list) michelson_str 0tez in
    edition_addr