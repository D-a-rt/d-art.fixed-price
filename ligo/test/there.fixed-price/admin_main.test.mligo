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

// -- Update_permission_manager --

// Success
let test_contract_update_permission_manager =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    let _gas = Test.transfer_to_contract_exn contract (Admin  ((Update_permission_manager (admin)): admin_entrypoints)) 0tez in    

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.permission_manager = admin) "Admin -> Update_permission_manager - Success : Permission manager should be updated" in

    "Passed"

// Should fail if not admin
let test_contract_update_permission_manager_not_admin =
    let _, contract_add,_ ,_, _  = get_fixed_price_contract (false) in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  ((Update_permission_manager (no_admin_addr)): admin_entrypoints)) 0tez in    

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
    let result = Test.transfer_to_contract contract (Admin  ((Update_permission_manager (admin) : admin_entrypoints))) 1tez in    

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


// -- REFERRAL ACTIVATED --

// Success
let test_referral_activated =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    let _gas = Test.transfer_to_contract_exn contract (Admin  (Referral_activated (true))) 0tez in    

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.referral_activated = true) "Admin -> Referral_activated - True : Should be true" in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (Referral_activated (false))) 0tez in    

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.referral_activated = false) "Admin -> Referral_activated - False : Should be false" in
    "Passed"

// Should fail if not admin
let test_referral_activated_not_admin =
    let _, contract_add,_ ,_, _  = get_fixed_price_contract (false) in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  (Referral_activated (true))) 0tez in    

    match result with
        Success _gas -> failwith "Admin -> Referral_activated - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Referral_activated - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount passed as parameter
let test_referral_activated_with_amount =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  (Referral_activated (true))) 1tez in    

    match result with
        Success _gas -> failwith "Admin -> Referral_activated - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Referral_activated - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// -- Add_stable_coin --

// fail if already stable coin
let test_add_stable_coin_already_integraded =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (Add_stable_coin({fa2_base = { address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n}; mucoin = 1000000n}))) 0tez in    
    let result = Test.transfer_to_contract contract (Admin  (Add_stable_coin({fa2_base = { address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n}; mucoin = 1000000n}))) 0tez in    

    match result with
        Success _gas -> failwith "Admin -> Add_stable_coin - Already stable coin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_STABLE_COIN") ) "Admin -> Add_stable_coin - Already stable coin : Should not work if stable coin already registered" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail no amount
let test_add_stable_coin_no_amount =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract (Admin  (Add_stable_coin({fa2_base = { address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n}; mucoin = 1000000n}))) 1tez in    

    match result with
        Success _gas -> failwith "Admin -> Add_stable_coin - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Add_stable_coin - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if not admin
let test_add_stable_coin_not_admin =
    let _, contract_add, _, _, _  = get_fixed_price_contract (false) in
    
    let not_admin = Test.nth_bootstrap_account 7 in
    let () = Test.set_source not_admin in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract (Admin  (Add_stable_coin({fa2_base = { address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n}; mucoin = 1000000n}))) 0tez in    

    match result with
        Success _gas -> failwith "Admin -> Add_stable_coin - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Add_stable_coin - no amount : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
    
// success
let test_add_stable_coin_succes =
    let _, contract_add, _, _, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract (Admin  (Add_stable_coin({fa2_base = { address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n}; mucoin = 1000000n}))) 0tez in    

    match result with
        Success _gas -> (
            let str = Test.get_storage contract_add in
            match Big_map.find_opt { address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n} str.stable_coin with
                   Some mucoin -> (
                    let () = assert_with_error ( mucoin = 1000000n ) "Admin -> Add_stable_coin - success : Stable coin was not added to big map" in
                    "Passed"
                )
                |    None -> failwith "Admin -> Add_stable_coin - success : Stable coin was not added to big map"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin -> Add_stable_coin - success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"    
    
// -- Remove_stable_coin --

// fail no amount
let test_remove_stable_coin_no_amount =
    let _, contract_add,_ ,_, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract (Admin  (Remove_stable_coin({ address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n}))) 1tez in    

    match result with
        Success _gas -> failwith "Admin -> Remove_stable_coin - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Remove_stable_coin - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if not admin
let test_remove_stable_coin_not_admin =
    let _, contract_add, _, _, _  = get_fixed_price_contract (false) in
    
    let not_admin = Test.nth_bootstrap_account 7 in
    let () = Test.set_source not_admin in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract (Admin  (Remove_stable_coin({ address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n }))) 0tez in    

    match result with
        Success _gas -> failwith "Admin -> Remove_stable_coin - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Remove_stable_coin - not admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// success
let test_remove_stable_coin_not_admin =
    let _, contract_add, _, _, admin  = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (Remove_stable_coin({ address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n}))) 0tez in    
    
    let str = Test.get_storage contract_add in
    match Big_map.find_opt { address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n} str.stable_coin with
            None -> "Passed"
        |   Some _ -> failwith "Admin -> Remove_stable_coin - success : Stable coin was not added to big map"
