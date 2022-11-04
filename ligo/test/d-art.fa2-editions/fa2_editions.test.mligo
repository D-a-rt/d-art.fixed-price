#import "storage.test.mligo" "FA2_STR"
#import "../../d-art.fa2-editions/multi_nft_token_editions.mligo" "FA2_E"

// -- Burn Token --

// Fail no amount
let test_burn_token_no_amount = 
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
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
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
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
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
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
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
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
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
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
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_E.split list );
    } : FA2_E.mint_edition_param ) in

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
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_E.split list );
    } : FA2_E.mint_edition_param ) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Not a minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_MINTER") ) "Mint_editions - Not a minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if royalties exceed 25 percent
let test_mint_edition_royalties_exceed_25_pct = 
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 251n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_E.split list );
    } : FA2_E.mint_edition_param ) in

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
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 501n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_E.split list );
    } : FA2_E.mint_edition_param ) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    let () = match result with
            Success _gas -> failwith "Mint_editions - Splits != 100% : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Mint_editions - Splits > 100% : Should not work if Splits exceed 100%" in
                ()
            )
        |   Fail _ -> failwith "Internal test failure"
    in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 499n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_E.split list );
    } : FA2_E.mint_edition_param ) in

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
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(true) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_E.split list );
    } : FA2_E.mint_edition_param ) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
            Success _gas -> failwith "Mint_editions - Minting closed : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTING_PAUSED") ) "Mint_editions - Minting closed : Should not work if minting is paused" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"
    

// Success 
let test_mint_edition_success = 
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : FA2_E.split list );
    } : FA2_E.mint_edition_param ) in

    let result = Test.transfer_to_contract contract (Mint_editions mint_editions_param) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            match Big_map.find_opt 0n new_str.assets.ledger with 
                    Some address -> (
                        let () = assert_with_error (address = minter) "Mint_editions - No receivers : Receiver should be minter" in
                        "Passed"
                    ) 
                |   None -> failwith "Mint_editions - No receivers : Token should exist"
            
        )
    |   Fail (Rejected (err, _)) -> (
            failwith "Mint_editions - No receivers : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"


// -- Update Metadata

// Fail if not admin
let test_update_metadata_no_admin =
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
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
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
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
            failwith "Update_metadata (Serie originated fa2 contract) - Update metadata success : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"
