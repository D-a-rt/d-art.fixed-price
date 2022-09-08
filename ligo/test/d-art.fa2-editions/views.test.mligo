#import "storage.test.mligo" "FA2_STR"
#import "../../d-art.fa2-editions/views.mligo" "FA2_V"
#import "../../d-art.fa2-editions/interface.mligo" "FA2_I"

// Test on views are only meant to check the success as it's not possible to 
// catch a failwith while testing a view using the Ligo Test API (I might have missed it)

// -- Is minter --

let test_is_token_minter_view =
    let contract_t_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_t_add in 

    let minter = Test.nth_bootstrap_account 7 in
    let is_minter = FA2_V.is_token_minter ((minter, 0n : address * FA2_I.token_id), strg) in

    let () = assert_with_error (is_minter) "Views - Is minter : This test should pass, correct minter specified" in
    "Passed"


let test_is_token_minter_view_false =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let not_minter = Test.nth_bootstrap_account 6 in
    let is_minter = FA2_V.is_token_minter ((not_minter, 0n : address * FA2_I.token_id ), strg) in

    let () = assert_with_error (is_minter <> true) "Views - Is minter : This test should pass, wrong minter specified" in
    "Passed"

// -- Minter --

// Success
let test_minter_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let minter_address = FA2_V.minter (1n, strg) in

    let () = assert_with_error (minter_address = minter) "Views - Minter : This test should pass, wrong minter specified" in
    "Passed"

// -- Views - royalty --
// Success
let test_royalty_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let royalty = FA2_V.royalty (1n, strg) in

    let () = assert_with_error (royalty = 150n) "Views - Royalty : This test should pass, wrong royalty specified" in
    "Passed"


// -- Views - royalty splits --
// Success
let test_royalty_splits_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let royalties = FA2_V.royalty_splits (1n, strg) in

    let roy = ({
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )]
    } : FA2_V.royalties) in

    let () = assert_with_error (royalties = roy) "Views - Royalty splits : This test should pass, wrong minter specified" in
    "Passed"


// -- Views - splits --
// Success
let test_splits_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let splits = FA2_V.splits (1n, strg) in

    let spts = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )] in

    let () = assert_with_error (splits = spts) "Views - Splits : This test should pass, wrong minter specified" in
    "Passed"


// -- Views - royalty distribution --
// Success
let test_royalty_distribution_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let distribution = FA2_V.royalty_distribution (1n, strg) in

    let distri = (minter, ({
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )]
    } : FA2_V.royalties)) in

    let () = assert_with_error (distribution = distri) "Views - Splits : This test should pass, wrong minter specified" in
    "Passed"

// -- Views - token metadata --
// Success
let test_token_metadata_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let token_metadata = FA2_V.token_metadata (1n, strg) in

    let token_m = ({
        token_id = 1n;
        token_info = Map.literal [("edition_number"), Bytes.pack(2n) ]
    } : FA2_V.token_metadata) in

    let () = assert_with_error (token_metadata = token_m) "Views - Token metadata : This test should pass, wrong token_metadata" in
    "Passed"

// -- Views - is token unique edition --
// Success
let test_is_unique_edition =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let is_unique_edition = FA2_V.is_unique_edition(1n, strg) in

    let () = assert_with_error (is_unique_edition = false) "Views - Is unique edition : This test should pass, test is unique edition" in
    "Passed"


// -- FA2 editions version originated from Serie factory contract

#include "../../d-art.fa2-editions/fa2_editions_factory.mligo"

let get_serie_originated_initial_storage (mr: bool) : ( ((editions_entrypoints, editions_storage) typed_address) * address * address * address ) = 
    let () = Test.reset_state 8n ([]: tez list) in
    
    // Admin storage
    let admin = Test.nth_bootstrap_account 0 in
 
    let minter = Test.nth_bootstrap_account 7 in

    let factory_contract_address = FA2_STR.get_factory_contract () in

    let admin_str : admin_storage = {
        admin = minter;
        minting_revoked = mr;
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
    let token_metadata = (Big_map.empty : (token_id, token_metadata) big_map) in
    
    let asset_str = {
        ledger = ledger;
        operators = operators;
        token_metadata = token_metadata;
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
        next_edition_id = 1n;
        max_editions_per_run = 250n ;
        editions_metadata = editions_metadata;
        assets = asset_str;
        admin = admin_str;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate editions_main str 0tez in
    taddr, admin, owner1, minter


// -- Is minter --

let test_factory_originated_is_token_minter_view =
    let contract_t_add, _, _, minter = get_serie_originated_initial_storage(false) in
    let strg = Test.get_storage contract_t_add in 

    let minter = Test.nth_bootstrap_account 7 in
    let is_minter = is_token_minter ((minter, 0n : address * token_id), strg) in

    let () = assert_with_error (is_minter) "Views - Is minter : This test should pass, correct minter specified" in
    "Passed"

let test_factory_originated_is_token_minter_view_false =
    let contract_add, _, _, minter = get_serie_originated_initial_storage(false) in
    let strg = Test.get_storage contract_add in

    let not_minter = Test.nth_bootstrap_account 6 in
    let is_minter = is_token_minter ((not_minter, 0n : address * token_id ), strg) in

    let () = assert_with_error (is_minter <> true) "Views - Is minter : This test should pass, wrong minter specified" in
    "Passed"

// -- Minter --

// Success
let test_factory_originated_minter_view =
    let contract_add, _, _, minter_add = get_serie_originated_initial_storage(false) in
    let strg = Test.get_storage contract_add in

    let minter_address = minter (1n, strg) in

    let () = assert_with_error (minter_address = minter_add) "Views - Minter : This test should pass, wrong minter specified" in
    "Passed"

// -- Views - royalty distribution --

// Success
let test_factory_originated_royalty_distribution_view =
    let contract_add, _, _, minter = get_serie_originated_initial_storage(false) in
    let strg = Test.get_storage contract_add in

    let distribution = royalty_distribution (1n, strg) in

    let distri = (minter, ({
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )]
    } : royalties)) in

    let () = assert_with_error (distribution = distri) "Views - Splits : This test should pass, wrong minter specified" in
    "Passed"
