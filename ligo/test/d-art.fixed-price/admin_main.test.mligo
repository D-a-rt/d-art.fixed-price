#include "storage.test.mligo" 

// -- UPDATE FEE --

// Success update fee
let test_primary_update_fee =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let current_fee_addr = admin in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let _gas_0 = Test.transfer_to_contract_exn contract
        (Admin
            (Update_primary_fee ({
                address = admin;
                percent = 40n;
            } : fee_data ))) 0tez in
    
    let new_fee_percent_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_percent_str.fee_primary.percent = 40n) "Admin -> Update_primary_fee - Success (percentage): Wrong fee percent after update" in

    // Test change fee address
    let new_fee_addr = Test.nth_bootstrap_account 1 in
    let _gas_1 = Test.transfer_to_contract_exn contract
        (Admin
            (Update_primary_fee ({
                address = new_fee_addr;
                percent = 40n;
            } : fee_data ))) 0tez in

    let new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_addr_str.fee_primary.address = new_fee_addr) "Admin -> Update_primary_fee - Success (address) : Wrong fee address after update" in

    // Test change fee address & percentage
    let _gas_2 = Test.transfer_to_contract_exn contract
        (Admin
            (Update_primary_fee ({
                address = current_fee_addr;
                percent = 10n;
            } : fee_data ))) 0tez in

    let second_new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (second_new_fee_addr_str.fee_primary.address = current_fee_addr) "Admin -> Update_primary_fee - Success (address & percentage) : Wrong fee address after update" in
    let () = assert_with_error (second_new_fee_addr_str.fee_primary.percent = 10n) "Admin -> Update_primary_fee - Success (address & percentage) : Wrong fee percent after update" in
    "Passed"

// Should fail if percentage is greater than 50
let test_primary_update_fee_negative_value =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let current_fee_addr = admin in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let result = Test.transfer_to_contract contract
        (Admin
            (Update_primary_fee ({
                address = admin;
                percent = 251n;
            } : fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> Update_primary_fee - Greater than 25 : This test should fail"
    |   Fail (Rejected (err, _)) ->  (
        let () = assert_with_error ( Test.michelson_equal err (Test.eval "PERCENTAGE_MUST_BE_MAXIUM_25_PERCENT") ) "Admin -> Update_primary_fee - Greater than 25 : Should not work if percentage is greater than 50" in
        "Passed"
    )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if not admin
let test_primary_update_fee_no_admin = 
    let _, contract_add,_ ,_, _  = get_fixed_price_contract (false) in
    let contract = Test.to_contract contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (Update_primary_fee ({
                address = no_admin_addr;
                percent = 40n;
            } : fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> Update_primary_fee - Wrong admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Update_primary_fee - Wrong admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"
    
// Should fail if amount passed as parameter
let test_primary_update_fee_with_amount = 
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (Update_primary_fee ({
                address = admin;
                percent = 40n;
            } : fee_data ))) 1tez in
    
    match result with
        Success _gas -> failwith "Admin -> Update_primary_fee - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Update_primary_fee - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success update fee
let test_secondary_update_fee =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let current_fee_addr = admin in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let _gas_0 = Test.transfer_to_contract_exn contract
        (Admin
            (Update_secondary_fee ({
                address = admin;
                percent = 40n;
            } : fee_data ))) 0tez in
    
    let new_fee_percent_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_percent_str.fee_secondary.percent = 40n) "Admin -> Update_secondary_fee - Success (percentage): Wrong fee percent after update" in

    // Test change fee address
    let new_fee_addr = Test.nth_bootstrap_account 1 in
    let _gas_1 = Test.transfer_to_contract_exn contract
        (Admin
            (Update_secondary_fee ({
                address = new_fee_addr;
                percent = 40n;
            } : fee_data ))) 0tez in

    let new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_addr_str.fee_secondary.address = new_fee_addr) "Admin -> Update_secondary_fee - Success (address) : Wrong fee address after update" in

    // Test change fee address & percentage
    let _gas_2 = Test.transfer_to_contract_exn contract
        (Admin
            (Update_secondary_fee ({
                address = current_fee_addr;
                percent = 10n;
            } : fee_data ))) 0tez in

    let second_new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (second_new_fee_addr_str.fee_secondary.address = current_fee_addr) "Admin -> Update_secondary_fee - Success (address & percentage) : Wrong fee address after update" in
    let () = assert_with_error (second_new_fee_addr_str.fee_secondary.percent = 10n) "Admin -> Update_secondary_fee - Success (address & percentage) : Wrong fee percent after update" in
    "Passed"

// Should fail if percentage is greater than 50
let test_secondary_update_fee_negative_value =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let current_fee_addr = admin in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let result = Test.transfer_to_contract contract
        (Admin
            (Update_secondary_fee ({
                address = admin;
                percent = 251n;
            } : fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> Update_secondary_fee - Greater than 25 : This test should fail"
    |   Fail (Rejected (err, _)) ->  (
        let () = assert_with_error ( Test.michelson_equal err (Test.eval "PERCENTAGE_MUST_BE_MAXIUM_25_PERCENT") ) "Admin -> Update_secondary_fee - Greater than 25 : Should not work if percentage is greater than 50" in
        "Passed"
    )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if not admin
let test_secondary_update_fee_no_admin = 
    let _, contract_add,_ ,_, _  = get_fixed_price_contract (false) in
    let contract = Test.to_contract contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (Update_secondary_fee ({
                address = no_admin_addr;
                percent = 40n;
            } : fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> Update_secondary_fee - Wrong admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Update_secondary_fee - Wrong admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"
    
// Should fail if amount passed as parameter
let test_secondary_update_fee_with_amount = 
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (Update_secondary_fee ({
                address = admin;
                percent = 40n;
            } : fee_data ))) 1tez in
    
    match result with
        Success _gas -> failwith "Admin -> Update_secondary_fee - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Update_secondary_fee - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// -- UPDATE PUBLIC KEY --

// Success update public_key
let test_update_public_key = 
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in

    let new_account : (string * key) = Test.new_account () in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (Update_public_key (new_account.1))) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (Test.eval(new_str.admin.pb_key) = Test.eval(new_account.1)) "Admin -> Update_public_key - Success : Wrong key after update" in
    "Passed"

// Should fail if not admin
let test_update_public_key_not_admin = 
    let _, contract_add,_ ,_, _  = get_fixed_price_contract (false) in
    
    let new_account : (string * key) = Test.new_account () in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let contract = Test.to_contract contract_add in
    
    let result = Test.transfer_to_contract contract (Admin (Update_public_key (new_account.1))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> Update_public_key - Wrong admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Update_public_key - Wrong admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Should fail if amount passed as parameter
let test_update_public_key_with_amount =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let new_account : (string * key) = Test.new_account () in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract (Admin (Update_public_key (new_account.1))) 1tez in
    
    match result with
        Success _gas -> failwith "Admin -> Update_public_key - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Update_public_key - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// -- Update_permission_manager --

// Success
let test_contract_update_permission_manager =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    let _gas = Test.transfer_to_contract_exn contract (Admin  (Update_permission_manager (admin))) 0tez in    

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.permission_manager = admin) "Admin -> Update_permission_manager - Success : Permission manager should be updated" in

    "Passed"

// Should fail if not admin
let test_contract_update_permission_manager_not_admin =
    let _, contract_add,_ ,_, _  = get_fixed_price_contract (false) in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  (Update_permission_manager (no_admin_addr))) 0tez in    

    match result with
        Success _gas -> failwith "Admin -> Update_permission_manager - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Update_permission_manager - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount passed as parameter
let test_contract_update_permission_manager_with_amount =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  (Update_permission_manager (admin))) 1tez in    

    match result with
        Success _gas -> failwith "Admin -> Update_permission_manager - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Update_permission_manager - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// -- CONTRACT WILL UPDATE --

// Success
let test_contract_will_update =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    let _gas = Test.transfer_to_contract_exn contract (Admin  (Contract_will_update (true))) 0tez in    

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.contract_will_update = true) "Admin -> Contract_will_update - True : Should be true" in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (Contract_will_update (false))) 0tez in    

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.contract_will_update = false) "Admin -> Contract_will_update - True : Should be true" in
    "Passed"

// Should fail if not admin
let test_contract_will_update_not_admin =
    let _, contract_add,_ ,_, _  = get_fixed_price_contract (false) in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  (Contract_will_update (true))) 0tez in    

    match result with
        Success _gas -> failwith "Admin -> Contract_will_update - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Contract_will_update - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount passed as parameter
let test_contract_will_update_with_amount =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  (Contract_will_update (true))) 1tez in    

    match result with
        Success _gas -> failwith "Admin -> Contract_will_update - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Contract_will_update - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
