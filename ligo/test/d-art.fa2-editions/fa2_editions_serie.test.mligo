// -- FA2 editions version originated from Serie factory contract --
#import "storage_serie.test.mligo" "FA2_SERIE_STR"
#include "../../d-art.fa2-editions/compile_fa2_editions_serie.mligo"

// Fail no amount
let test_factory_originated_mint_edition_no_amount = 
    let contract_add, admin, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 10n;
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 1tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Mint_editions (Serie originated fa2 contract) - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if not contract admin
let test_factory_originated_mint_edition_not_admin = 
    let contract_add, admin, owner1, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 10n;
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
        
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Not contract admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Mint_editions (Serie originated fa2 contract) - Not contract admin : Should not work if not contract admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if to many editions
let test_factory_originated_mint_edition_too_many_editions = 
    let contract_add, admin, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let str = Test.get_storage contract_add in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = str.max_editions_per_run + 1n;
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Edition run too large : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_RUN_TOO_LARGE") ) "Mint_editions (Serie originated fa2 contract) - Edition run too large : Should not work if number of edition greater than max_editions_per_run" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if too low edition number
let test_factory_originated_mint_edition_0_editions = 
    let contract_add, admin, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 0n;
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Edition run too low : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") ) "Mint_editions (Serie originated fa2 contract) - Edition run too low : Should not work if number of edition is 0n" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if royalties exceed 25 percent
let test_factory_originated_mint_edition_royalties_exceed_25_pct = 
    let contract_add, admin, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 0n;
        royalty = 251n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Royalties > 25% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_CANNOT_EXCEED_25_PERCENT") ) "Mint_editions (Serie originated fa2 contract) - Royalties > 25% : Should not work if royalties exceed 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if split not equal to 100%
let test_factory_originated_mint_edition_splits_exceed_100_pct = 
    let contract_add, admin, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 501n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 0tez in

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
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 499n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Splits != 100% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Mint_editions (Serie originated fa2 contract) - Splits < 100% : Should not work if Splits lower then 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail if revoke minting true
let test_factory_originated_mint_edition_revoked_minting = 
    let contract_add, admin, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(true) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 0tez in

    match result with
            Success _gas -> failwith "Mint_editions (Serie originated fa2 contract) - Minting revoked : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTING_IS_REVOKED") ) "Mint_editions (Serie originated fa2 contract) - Minting revoked : Should not work if minting is revoked" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"
    

// Success 
let test_factory_originated_mint_edition_success = 
    let contract_add, admin, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ([({
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param )] : mint_edition_param list) in

    let result = Test.transfer_to_contract contract ((Mint_editions mint_editions_param) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            
            let () = match Big_map.find_opt 50n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions (Serie originated fa2 contract) - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - No receivers : Token should exist"
            in
            // The non specified token should be assigned to the minter
            let () = match Big_map.find_opt 51n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions (Serie originated fa2 contract) - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - No receivers : Token should exist"
            in
            let () = match Big_map.find_opt 52n new_str.assets.ledger with 
                    Some address -> assert_with_error (address = minter) "Mint_editions - No receivers : Receiver should be minter"
                |   None -> failwith "Mint_editions (Serie originated fa2 contract) - No receivers : Token should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Mint_editions (Serie originated fa2 contract) - No receivers : This test should pass"
    |   Fail _ -> failwith "Internal test failure"


// -- Update Metadata

// Fail if not admin
let test_factory_originated_update_metadata_no_admin =
    let contract_add, _, owner1, _ = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Update_metadata ("54657374206d657373616765207465746574657465" : bytes) : editions_entrypoints ) 0tez in

    match result with
            Success _gas -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Update_metadata (Serie originated fa2 contract) - Update metadata : Should not work if not an admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"
      
let test_factory_originated_update_metadata_success =
    let contract_add, _, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract (Update_metadata ("54657374206d65737361676520746574657465746567" : bytes) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            let () = match Big_map.find_opt "" new_str.metadata with 
                    Some meta -> assert_with_error (meta = ("54657374206d65737361676520746574657465746567" : bytes)) "Update_metadata (Serie originated fa2 contract) - Update metadata success : Metadata shoule be updated"
                |   None -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata : Metadata should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata success : This test should pass"
    
    |   Fail _ -> failwith "Internal test failure"

// -- Upgrade License

// no amount
let test_factory_originated_upgrade_license_no_amount =
    let contract_add, _, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = True; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 1tez in

    match result with
        Success _gas -> failwith "Upgrade_license (Serie originated fa2 contract) - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Upgrade_license (Serie originated fa2 contract) - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// token undefined
let test_factory_originated_upgrade_license_token_undefined =
    let contract_add, _, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 10000n; license = {upgradeable = True; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Upgrade_license (Serie originated fa2 contract) - Token undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_TOKEN_UNDEFINED") ) "Upgrade_license (Serie originated fa2 contract) - Token undefined : Should not work if token undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// sender must be minter 
let test_factory_originated_upgrade_license_sender_must_be_minter =
    let contract_add, _, owner1, _ = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = True; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Upgrade_license (Serie originated fa2 contract) - Sender must be minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SENDER_MUST_BE_MINTER") ) "Upgrade_license (Serie originated fa2 contract) - Sender must be minter : Should not work if sender is not minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// license sealed
let test_factory_originated_upgrade_license_sealed =
    let contract_add, _, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let _gas = Test.transfer_to_contract_exn contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = False; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in
    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = True; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Upgrade_license (Serie originated fa2 contract) - License sealed : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "LICENSE_SEALED") ) "Upgrade_license (Serie originated fa2 contract) - License sealed : Should not work if the license is sealed" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_factory_originated_upgrade_license_success =
    let contract_add, _, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = False; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in

  match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            
            let () = match Big_map.find_opt 0n new_str.editions_metadata with 
                    Some edition_metadata -> assert_with_error (edition_metadata.license = {upgradeable = False; hash = ("54657374206d65737361676520746574657465746567" : bytes)}) "Upgrade_license (Serie originated fa2 contract) - Success : License should be upgraded"
                |   None -> failwith "Upgrade_license (Serie originated fa2 contract) - Success : Token should exist"
            in

            "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Upgrade_license (Serie originated fa2 contract) - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"
