#import "storage.test.mligo" "FA2_STR"
#include "../../d-art.art-factories/serie_factory.mligo"

// TEST FILE FOR MAIN ENTRYPOINTS

// -- Update permission manager --

// Fail if amount
let test_update_permission_manager_no_amount =
    let contract_add, _ = FA2_STR.get_serie_factory_contract() in
    let contract = Test.to_contract contract_add in

    // Obviously it should be a KT.. address using tz.. one for conveniance
    let new_manager = Test.nth_bootstrap_account 3 in
    
    let result = Test.transfer_to_contract contract ((Update_permission_manager (new_manager)) : art_factory) 1tez in

    match result with
        Success _gas -> failwith "Update_permission_manager - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Update_permission_manager - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// Fail if sender not admin
let test_update_permission_manager_not_admin =
    let contract_add, _ = FA2_STR.get_serie_factory_contract() in
    let contract = Test.to_contract contract_add in

    // Obviously it should be a KT.. address using tz.. one for conveniance
    let new_manager = Test.nth_bootstrap_account 3 in
    let () = Test.set_source new_manager in

    let result = Test.transfer_to_contract contract ((Update_permission_manager (new_manager)) : art_factory) 0tez in

    match result with
        Success _gas -> failwith "Update_permission_manager - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Update_permission_manager - Not admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success
let test_update_permission_manager_success =
    let contract_add, _ = FA2_STR.get_serie_factory_contract() in
    let contract = Test.to_contract contract_add in

    // Obviously it should be a KT.. address using tz.. one for conveniance
    let admin = Test.nth_bootstrap_account 0 in
    let new_manager = Test.nth_bootstrap_account 3 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract ((Update_permission_manager (new_manager)) : art_factory) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            let () = assert_with_error ( new_str.permission_manager = new_manager) "Update_permission_manager - Success : This test should pass" in
            "Passed"
        )
    |   Fail (Rejected (_err, _)) ->  failwith "Update_permission_manager - Success : This test should pass"
        
    |   Fail _ -> failwith "Internal test failure"


// -- Create serie --

// Fail if not minter
let test_create_serie_not_minter =
    let contract_add, _ = FA2_STR.get_serie_factory_contract() in
    let contract = Test.to_contract contract_add in
    
    let not_minter = Test.nth_bootstrap_account 3 in

    let () = Test.set_source not_minter in
    let result = Test.transfer_to_contract contract ((Create_serie ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes); symbol = ("4a3a504e" : bytes) })) : art_factory) 0tez in 

    match result with
        Success _gas -> failwith "Create_serie - Not minter : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_MINTER") ) "Create_serie - Not minter : Should not work if not a minter" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Fail if no amount
let test_create_serie_no_amount =
    let contract_add, minter = FA2_STR.get_serie_factory_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Create_serie ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes); symbol = ("4a3a504e" : bytes) })) : art_factory) 1tez in 

    match result with
        Success _gas -> failwith "Create_serie - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Create_serie - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"       

// Success
let test_create_serie =
    let contract_add, minter = FA2_STR.get_serie_factory_contract() in
    let contract = Test.to_contract contract_add in

    let old_strg = Test.get_storage contract_add in

    let () = Test.set_source minter in

    let _gas = Test.transfer_to_contract_exn contract ((Create_serie ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes); symbol = ("4a3a504e" : bytes) })) : art_factory) 0tez in 

    let new_strg = Test.get_storage contract_add in

    // Check next_edition_id
    if old_strg.next_serie_id + 1n <> new_strg.next_serie_id
    then "Create_serie - Success : This test should pass : next_serie_id should be incremented" 
    else
    // Check serie is added to series big_map
    match Big_map.find_opt 0n new_strg.series with
        None -> "Create_serie - Success : This test should pass : Serie should be present in the series big_map"
        | Some serie -> (
            if serie.minter <> minter
            then "Create_serie - Success : This test should pass : Minter of the serie should be the sender"
            else "Passed"
            // Check if serie storage is set properly (Not supported yet)
            // let contract_typed_add : (FA2.editions_entrypoints, FA2.editions_storage) typed_address = Test.cast_address serie.address in
            // let originated_contract_strg = Test.get_storage contract_typed_add in
            
            // if originated_contract_strg.admin.admin <> minter
            // then "Create_serie - Success : This test should pass : Admin of the serie should be the sender"
            // else
            // if originated_contract_strg.admin.minting_revoked = true
            // then "Create_serie - Success : This test should pass : Minting should not be revoked at origination"
            // else "Passed"
        )   
    

    

    