#import "storage.test.mligo" "FA2_STR"
#include "../../d-art.serie-factory/serie_factory.mligo"
// TEST FILE FOR ADMIN ENTRYPOINTS


// -- Add Minter --

// Fail not admin
let test_add_minter_not_admin = 
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let owner1 = Test.nth_bootstrap_account 1 in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Add_minter (owner1))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Add_minter - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Add_minter - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_add_minter_no_amount =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let owner1 = Test.nth_bootstrap_account 1 in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Add_minter (owner1))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Add_minter - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Add_minter - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail already minter
let test_add_minter_already_minter =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let new_minter = Test.nth_bootstrap_account 2 in

    let result = Test.transfer_to_contract contract (Admin (Add_minter (new_minter))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Add_minter - Already minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_MINTER") ) "Admin -> Add_minter - Already minter : Should not work if already minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_add_minter =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    let owner1 = Test.nth_bootstrap_account 1 in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Add_minter (owner1))) 0tez in

    let new_str = Test.get_storage contract_add in
    
    match Big_map.find_opt owner1 new_str.minters with
            Some _ -> "Passed"
        |   None -> "Admin -> Add_minter - Success : This test should pass :  Minter not in big_map" 
    

// -- Remove minter --

// Fail if not admin
let test_remove_minter_not_admin = 
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let owner1 = Test.nth_bootstrap_account 1 in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Remove_minter (owner1))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Add_minter - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Add_minter - No admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_remove_minter_no_amount =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let owner1 = Test.nth_bootstrap_account 1 in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Remove_minter (owner1))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Remove_minter - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Remove_minter - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if not minter
let test_remove_minter_not_minter =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    let owner1 = Test.nth_bootstrap_account 1 in
    
    let result = Test.transfer_to_contract contract (Admin (Remove_minter (owner1))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Remove_minter - Not minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTER_NOT_FOUND") ) "Admin -> Remove_minter - Not minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_remove_minter =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    
    let new_minter = Test.nth_bootstrap_account 2 in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Remove_minter (new_minter))) 0tez in

    let new_str = Test.get_storage contract_add in
    match Big_map.find_opt new_minter new_str.minters with
            Some _ -> "Admin -> Remove_minter - Success : This test should pass :  Minter already in big_map" 
        |   None -> "Passed"
    
// -- Pause serie creation --

// Fail if not admin
let test_pause_serie_creation_no_admin =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    
    let new_minter = Test.nth_bootstrap_account 2 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract (Admin (Pause_serie_creation (true))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Pause serie creation - Not an admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Pause serie creation - Not an admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Fail if amount
let test_pause_serie_creation_no_amount =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    
    let new_minter = Test.nth_bootstrap_account 2 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract (Admin (Pause_serie_creation (true))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Pause serie creation - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Pause serie creation - Not admin : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_pause_serie_creation =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Pause_serie_creation (true))) 0tez in

    let new_str = Test.get_storage contract_add in
    if new_str.origination_paused
    then "Passed"
    else "Admin -> Pause serie creation - Success : This test should pass : origination_paused should be set to true" 
    
// -- Send_admin_invitation --

// Fail if not admin
let test_send_admin_invitation_not_admin = 
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    
    let new_admin = Test.nth_bootstrap_account 3 in

    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract (Admin (Send_admin_invitation ({
        new_admin = new_admin
    } : admin_invitation_param))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Send_admin_invitation - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Send_admin_invitation - No amount : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if amount
let test_send_admin_invitation_no_amount = 
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    
    let new_admin = Test.nth_bootstrap_account 3 in

    let result = Test.transfer_to_contract contract (Admin (Send_admin_invitation ({
        new_admin = new_admin
    } : admin_invitation_param))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Send_admin_invitation - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Send_admin_invitation - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_send_admin_invitation =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let new_admin = Test.nth_bootstrap_account 3 in

    let result = Test.transfer_to_contract contract (Admin (Send_admin_invitation ({
        new_admin = new_admin
    } : admin_invitation_param))) 0tez in

    let new_str = Test.get_storage contract_add in
    match new_str.admin.pending_admin with
            Some admin -> (
                if admin = new_admin
                then "Passed"
                else "Admin -> Send_admin_invitation - Success : This test should pass :  Wrong pending admin in the storage" 
            )
        |   None -> "Admin -> Send_admin_invitation - Success : This test should pass :  No pending admin in the storage" 

// -- Revoke_admin_invitation --

// Fail if not admin
let test_revoke_admin_invitation_not_admin = 
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    
    let new_admin = Test.nth_bootstrap_account 3 in

    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract (Admin (Revoke_admin_invitation () )) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Revoke_admin_invitation - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Revoke_admin_invitation - No amount : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if amount
let test_revoke_admin_invitation_no_amount = 
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    
    let new_admin = Test.nth_bootstrap_account 3 in

    let result = Test.transfer_to_contract contract (Admin (Revoke_admin_invitation ())) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Revoke_admin_invitation - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Revoke_admin_invitation - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_revoke_admin_invitation =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let new_admin = Test.nth_bootstrap_account 3 in

    let result = Test.transfer_to_contract contract (Admin (Revoke_admin_invitation ())) 0tez in

    let new_str = Test.get_storage contract_add in
    match new_str.admin.pending_admin with
            Some _ -> "Admin -> Revoke_admin_invitation - Success : This test should pass : Pending admin shouldn't be set" 
        |   None -> "Passed" 


