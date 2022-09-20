#import "storage.test.mligo" "FA2_STR"
#import "../../d-art.fa2-editions/interface.mligo" "FA2_I"
#import "../../d-art.fa2-editions/multi_nft_token_editions.mligo" "FA2_E"

// -- Burn Token --

// Fail no amount
let test_burn_token_no_amount = 
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Burn_token ({ owner = owner1; token_id = 1n;})) 1tez in

    match result with
        Success _gas -> failwith "Burn_token - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Burn_token - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if not owner
let test_burn_token_not_owner = 
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Burn_token ({ owner = owner1; token_id = 3n;})) 0tez in

    match result with
        Success _gas -> failwith "Burn_token - Not owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_INSUFFICIENT_BALANCE") ) "Burn_token - Not owner : Should not work if not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if operator
let test_burn_token_if_operator = 
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let operator1 = Test.nth_bootstrap_account 4 in
    let () = Test.set_source operator1 in

    let result = Test.transfer_to_contract contract (Burn_token ({ owner = operator1; token_id = 1n;})) 0tez in

    match result with
        Success _gas -> failwith "Burn_token - Is operator : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_INSUFFICIENT_BALANCE") ) "Burn_token - Is operator : Should not work if sender is an operator" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Fail if token undefined
let test_burn_token_token_undefined = 
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Burn_token ({ owner = owner1; token_id = 9879n;})) 0tez in

    match result with
        Success _gas -> failwith "Burn_token - Token undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_TOKEN_UNDEFINED") ) "Burn_token - Token undefined : Should not work if token undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Success - should remove the token from the ledger_big map
let test_burn_token_token_undefined = 
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let _gas = Test.transfer_to_contract_exn contract (Burn_token ({ owner = owner1; token_id = 1n;})) 0tez in

    let new_strg = Test.get_storage contract_add in
    match Big_map.find_opt 1n new_strg.assets.ledger with
            Some _ -> failwith "Burn_token - Success : Token should be remove from the ledger"
        |   None -> "Passed"

// -- Mint editions --

// Fail no amount
let test_mint_edition_no_amount = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 10n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 1tez in

    match result with
        Success _gas -> failwith "Mint_editions - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Mint_editions - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if not minter
let test_mint_edition_not_minter = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 10n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Not a minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_MINTER") ) "Mint_editions - Not a minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if too many receivers
let test_mint_edition_too_many_receiver = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([admin; owner1] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Too many receivers : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "MORE_RECEIVERS_THAN_EDITIONS") ) "Mint_editions - Too many receivers : Should not work if number of receivers is greater than edition number" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if to many editions
let test_mint_edition_too_many_editions = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = str.max_editions_per_run + 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Edition run too large : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_RUN_TOO_LARGE") ) "Mint_editions - Edition run too large : Should not work if number of edition greater than max_editions_per_run" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if too low edition number
let test_mint_edition_0_editions = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 0n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Edition run too low : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") ) "Mint_editions - Edition run too low : Should not work if number of edition is 0n" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if royalties exceed 25 percent
let test_mint_edition_royalties_exceed_25_pct = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 0n;
        royalty = 251n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Royalties > 25% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_CANNOT_EXCEED_25_PERCENT") ) "Mint_editions - Royalties > 25% : Should not work if royalties exceed 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if split not equal to 100%
let test_mint_edition_splits_exceed_100_pct = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 501n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    let () = match result with
            Success _gas -> failwith "Mint_editions - Splits != 100% : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Mint_editions - Splits > 100% : Should not work if Splits exceed 100%" in
                ()
            )
        |   Fail _ -> failwith "Internal test failure"
    in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 499n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Splits != 100% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Mint_editions - Splits < 100% : Should not work if Splits lower then 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if pause minting true
let test_mint_edition_pause_minting = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(true, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
            Success _gas -> failwith "Mint_editions - Minting closed : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTING_PAUSED") ) "Mint_editions - Minting closed : Should not work if minting is paused" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"
    

// Success with nb receivers < edition number
let test_mint_edition_success_less_receivers_than_edition = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([owner1; admin] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            // 0 -> 249 : edition 1  (we already have 1 edition in the contract)
            let () = match Big_map.find_opt 250n new_str.assets.ledger with 
                    Some address -> (
                        assert_with_error (address = owner1) "Mint_editions - Less receivers than edition : Receiver should be minter"
                    )
                |   None -> failwith "Mint_editions - Less receivers than edition : Token should exist"
            in
            let () = match Big_map.find_opt 251n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = admin) "Mint_editions - Less receivers than edition : Receiver should be address"
                |   None -> failwith "Mint_editions - Less receivers than edition : Token should exist"
            in
            // The non specified token should be assigned to the minter
            let () = match Big_map.find_opt 252n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions - Less receivers than edition : Receiver should be admin"
                |   None -> failwith "Mint_editions - Less receivers than edition : Token should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
            failwith "Mint_editions - Less receivers than edition : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success receivers = edition nubmer
let test_mint_edition_success_receivers_equal_edition_nb = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 2n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([owner1; admin] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            // 0 -> 249 : edition 1  (we already have 1 edition in the contract)
            let () = match Big_map.find_opt 250n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = owner1) "Mint_editions - Receivers equal edition nb : Receiver should be address"
                |   None -> failwith "Mint_editions - Receivers equal edition nb : Token should exist"
            in
            // The non specified token should be assigned to the minter
            let () = match Big_map.find_opt 251n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = admin) "Mint_editions - Receivers equal edition nb : Receiver should be admin"
                |   None -> failwith "Mint_editions - Receivers equal edition nb : Token should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
            failwith "Mint_editions - Receivers equal edition nb : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success no receivers
let test_mint_edition_success_no_receivers = 
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_I.split list );
        receivers = ([] : address list);
    } : FA2_E.mint_edition_param )] : FA2_E.mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            // 0 -> 249 : edition 1  (we already have 1 edition in the contract)
            let () = match Big_map.find_opt 250n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions - No receivers : Token should exist"
            in
            // The non specified token should be assigned to the minter
            let () = match Big_map.find_opt 251n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions - No receivers : Token should exist"
            in
            let () = match Big_map.find_opt 252n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions - No receivers : Token should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
            failwith "Mint_editions - No receivers : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"


// -- Update Metadata

// Fail if not admin
let test_update_metadata_no_admin =
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let str = Test.get_storage contract_add in

    let result = Test.transfer_to_contract contract (Update_metadata ("54657374206d657373616765207465746574657465" : bytes) ) 0tez in

    match result with
            Success _gas -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Update_metadata (Serie originated fa2 contract) - Update metadata : Should not work if not an admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"
      
let test_update_metadata_success =
    let contract_add, admin, owner1, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let str = Test.get_storage contract_add in

    let result = Test.transfer_to_contract contract (Update_metadata ("54657374206d65737361676520746574657465746567" : bytes) ) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            let () = match Big_map.find_opt "" new_str.metadata with 
                    Some meta -> assert_with_error (meta = ("54657374206d65737361676520746574657465746567" : bytes)) "Update_metadata (Serie originated fa2 contract) - Update metadata success : Metadata shoule be updated"
                |   None -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata : Metadata should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
            let () = Test.log(err, "error") in
            failwith "Update_metadata (Serie originated fa2 contract) - Update metadata success : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"


// -- FA2 editions version originated from Serie factory contract --
#include "../../d-art.fa2-editions/compile_fa2_editions_factory.mligo"

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


// Fail no amount
let test_factory_originated_mint_edition_no_amount = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 10n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 1tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Mint_editions (Serie originated fa2 contract) - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if not contract admin
let test_factory_originated_mint_edition_not_admin = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 10n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Not contract admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Mint_editions (Serie originated fa2 contract) - Not contract admin : Should not work if not contract admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if too many receivers
let test_factory_originated_mint_edition_too_many_receiver = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([admin; owner1] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Too many receivers : This test should fail"
    |   Fail (Rejected (err, _)) -> (

            let () = assert_with_error ( Test.michelson_equal err (Test.eval "MORE_RECEIVERS_THAN_EDITIONS") ) "Mint_editions (Serie originated fa2 contract) - Too many receivers : Should not work if number of receivers is greater than edition number" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if to many editions
let test_factory_originated_mint_edition_too_many_editions = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = str.max_editions_per_run + 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Edition run too large : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_RUN_TOO_LARGE") ) "Mint_editions (Serie originated fa2 contract) - Edition run too large : Should not work if number of edition greater than max_editions_per_run" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if too low edition number
let test_factory_originated_mint_edition_0_editions = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 0n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Edition run too low : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") ) "Mint_editions (Serie originated fa2 contract) - Edition run too low : Should not work if number of edition is 0n" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if royalties exceed 25 percent
let test_factory_originated_mint_edition_royalties_exceed_25_pct = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 0n;
        royalty = 251n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Royalties > 25% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_CANNOT_EXCEED_25_PERCENT") ) "Mint_editions (Serie originated fa2 contract) - Royalties > 25% : Should not work if royalties exceed 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if split not equal to 100%
let test_factory_originated_mint_edition_splits_exceed_100_pct = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 501n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    let () = match result with
            Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Splits != 100% : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Mint_editions (Serie originated fa2 contract) - Splits > 100% : Should not work if Splits exceed 100%" in
                ()
            )
        |   Fail _ -> failwith "Internal test failure"
    in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 499n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Splits != 100% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Mint_editions (Serie originated fa2 contract) - Splits < 100% : Should not work if Splits lower then 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if revoke minting true
let test_factory_originated_mint_edition_revoked_minting = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(true) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
            Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Minting revoked : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTING_IS_REVOKED") ) "Mint_editions (Serie originated fa2 contract) - Minting revoked : Should not work if minting is revoked" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"
    

// Success with nb receivers < edition number
let test_factory_originated_mint_edition_success_less_receivers_than_edition = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([owner1; admin] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            // 0 -> 249 : edition 1  (we already have 1 edition in the contract)
            let () = match Big_map.find_opt 250n new_str.assets.ledger with 
                    Some address -> (
                        assert_with_error (address = owner1) "Mint_editions (Serie originated fa2 contract) - Less receivers than edition : Receiver should be minter"
                    )
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - Less receivers than edition : Token should exist"
            in
            let () = match Big_map.find_opt 251n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = admin) "Mint_editions (Serie originated fa2 contract) - Less receivers than edition : Receiver should be address"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - Less receivers than edition : Token should exist"
            in
            // The non specified token should be assigned to the minter
            let () = match Big_map.find_opt 252n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions (Serie originated fa2 contract) - Less receivers than edition : Receiver should be admin"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - Less receivers than edition : Token should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
            failwith "Mint_editions (Serie originated fa2 contract) - Less receivers than edition : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success receivers = edition nubmer
let test_factory_originated_mint_edition_success_receivers_equal_edition_nb = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 2n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([owner1; admin] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            // 0 -> 249 : edition 1  (we already have 1 edition in the contract)
            let () = match Big_map.find_opt 250n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = owner1) "Mint_editions (Serie originated fa2 contract) - Receivers equal edition nb : Receiver should be address"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - Receivers equal edition nb : Token should exist"
            in
            // The non specified token should be assigned to the minter
            let () = match Big_map.find_opt 251n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = admin) "Mint_editions (Serie originated fa2 contract) - Receivers equal edition nb : Receiver should be admin"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - Receivers equal edition nb : Token should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
            failwith "Mint_editions (Serie originated fa2 contract) - Receivers equal edition nb : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success no receivers
let test_factory_originated_mint_edition_success_no_receivers = 
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        receivers = ([] : address list);
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            // 0 -> 249 : edition 1  (we already have 1 edition in the contract)
            let () = match Big_map.find_opt 250n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions (Serie originated fa2 contract) - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - No receivers : Token should exist"
            in
            // The non specified token should be assigned to the minter
            let () = match Big_map.find_opt 251n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions (Serie originated fa2 contract) - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - No receivers : Token should exist"
            in
            let () = match Big_map.find_opt 252n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - No receivers : Token should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
            failwith "Mint_editions (Serie originated fa2 contract) - No receivers : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"


// -- Update Metadata

// Fail if not admin
let test_factory_originated_update_metadata_no_admin =
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let str = Test.get_storage contract_add in

    let result = Test.transfer_to_contract contract (Update_metadata ("54657374206d657373616765207465746574657465" : bytes) ) 0tez in

    match result with
            Success _gas -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Update_metadata (Serie originated fa2 contract) - Update metadata : Should not work if not an admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"
      
let test_factory_originated_update_metadata_success =
    let contract_add, admin, owner1, minter = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let result = Test.transfer_to_contract contract (Update_metadata ("54657374206d65737361676520746574657465746567" : bytes) ) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            let () = match Big_map.find_opt "" new_str.metadata with 
                    Some meta -> assert_with_error (meta = ("54657374206d65737361676520746574657465746567" : bytes)) "Update_metadata (Serie originated fa2 contract) - Update metadata success : Metadata shoule be updated"
                |   None -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata : Metadata should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
            let () = Test.log(err, "error") in
            failwith "Update_metadata (Serie originated fa2 contract) - Update metadata success : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"