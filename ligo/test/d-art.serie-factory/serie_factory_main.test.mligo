#import "storage.test.mligo" "FA2_STR"
#include "../../d-art.serie-factory/serie_factory.mligo"
#import "../../d-art.fa2-editions/fa2_editions_factory.mligo" "FA2"

// TEST FILE FOR MAIN ENTRYPOINTS

// -- Accrept_admin_invitation

// Fail if sender no pending admin
let test_accept_admin_invitation_not_pending_admin =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 3 in
    let () = Test.set_source new_admin in
    let result = Test.transfer_to_contract contract ( Accept_admin_invitation ({ accept = true } : admin_response_param )) 0tez in

    match result with
        Success _gas -> failwith "Accept_admin_invitation - No admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_PENDING_ADMIN") ) "Accept_admin_invitation - No admin : Should not work if no pending admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if sender not pending admin
let test_accept_admin_invitation_not_pending_admin =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 3 in
    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract (Admin (Send_admin_invitation ({ new_admin = new_admin } : admin_invitation_param))) 0tez in 
    
    let wrong_admin = Test.nth_bootstrap_account 4 in
    let () = Test.set_source wrong_admin in
    let result = Test.transfer_to_contract contract ( Accept_admin_invitation ({ accept = true } : admin_response_param )) 0tez in

    match result with
        Success _gas -> failwith "Accept_admin_invitation - Not pennding admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_PENDING_ADMIN") ) "Accept_admin_invitation - Not pennding admin : Should not work if sender is not pending admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if no amount
let test_accept_admin_invitation_no_amount =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 3 in
    
    let () = Test.set_source new_admin in    
    let result = Test.transfer_to_contract contract ( Accept_admin_invitation ({ accept = true } : admin_response_param )) 1tez in

    match result with
        Success _gas -> failwith "Accept_admin_invitation - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Accept_admin_invitation - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_accept_admin_invitation =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in
    
    let new_admin = Test.nth_bootstrap_account 3 in

    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract (Admin (Send_admin_invitation ({ new_admin = new_admin } : admin_invitation_param))) 0tez in 

    let () = Test.set_source new_admin in
    let _gas2 = Test.transfer_to_contract_exn contract ( Accept_admin_invitation ({ accept = true } : admin_response_param )) 0tez in

    let new_str = Test.get_storage contract_add in
    match new_str.admin.pending_admin with
            Some _ -> "Accept_admin_invitation - Success : This test should pass : Pending admin shouldn't be set" 
        |   None -> (
                if new_str.admin.admin = new_admin
                then "Passed"
                else "Accept_admin_invitation - Success : This test should pass : Admin should be updated" 
            )
   
// -- Create serie --

// Fail if not minter
let test_create_serie_not_minter =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in
    
    let not_minter = Test.nth_bootstrap_account 3 in

    let () = Test.set_source not_minter in
    let result = Test.transfer_to_contract contract (Create_serie ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) } : create_serie_entrypoint)) 0tez in 

    match result with
        Success _gas -> failwith "Create_serie - Not minter : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_MINTER") ) "Create_serie - Not minter : Should not work if not a minter" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Fail if no amount
let test_create_serie_no_amount =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in
    
    let minter = Test.nth_bootstrap_account 2 in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract (Create_serie ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) } : create_serie_entrypoint)) 1tez in 

    match result with
        Success _gas -> failwith "Create_serie - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Create_serie - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Fail if origination paused
let test_create_serie_origination_paused =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in
    
    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract (Admin (Pause_serie_creation (true))) 0tez in

    let minter = Test.nth_bootstrap_account 2 in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract (Create_serie ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) } : create_serie_entrypoint)) 0tez in 

    match result with
        Success _gas -> failwith "Create_serie - Origination paused : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "CREATION_OF_SERIES_PAUSED") ) "Create_serie - Origination paused : Should not work if origination is paused" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Success
let test_create_serie =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let old_strg = Test.get_storage contract_add in

    let minter = Test.nth_bootstrap_account 2 in

    let () = Test.set_source minter in
    let _gas = Test.transfer_to_contract_exn contract (Create_serie ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) } : create_serie_entrypoint)) 0tez in 

    let new_strg = Test.get_storage contract_add in

    // Check next_edition_id
    if old_strg.next_serie_id + 1n <> new_strg.next_serie_id
    then "Create_serie - Success : This test should pass : next_serie_id should be incremented" 
    else
    // Check serie is added to series big_map
    match Big_map.find_opt 1n new_strg.series with
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
    

    

    