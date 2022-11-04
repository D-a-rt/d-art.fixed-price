#include "storage.test.mligo" 

// -- UPDATE FEE --

// Success update fee
let test_primary_update_fee =
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let current_fee_addr = init_str.admin.address in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let _gas_0 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdatePrimaryFee ({
                address = init_str.admin.address;
                percent = 4n;
            } : fee_data ))) 0tez in
    
    let new_fee_percent_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_percent_str.fee_primary.percent = 4n) "Admin -> UpdatePrimaryFee - Success (percentage): Wrong fee percent after update" in

    // Test change fee address
    let new_fee_addr = Test.nth_bootstrap_account 1 in
    let _gas_1 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdatePrimaryFee ({
                address = new_fee_addr;
                percent = 4n;
            } : fee_data ))) 0tez in

    let new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_addr_str.fee_primary.address = new_fee_addr) "Admin -> UpdatePrimaryFee - Success (address) : Wrong fee address after update" in

    // Test change fee address & percentage
    let _gas_2 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdatePrimaryFee ({
                address = current_fee_addr;
                percent = 5n;
            } : fee_data ))) 0tez in

    let second_new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (second_new_fee_addr_str.fee_primary.address = current_fee_addr) "Admin -> UpdatePrimaryFee - Success (address & percentage) : Wrong fee address after update" in
    let () = assert_with_error (second_new_fee_addr_str.fee_primary.percent = 5n) "Admin -> UpdatePrimaryFee - Success (address & percentage) : Wrong fee percent after update" in
    "Passed"

// Should fail if percentage is greater than 50
let test_primary_update_fee_negative_value =
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let current_fee_addr = init_str.admin.address in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdatePrimaryFee ({
                address = init_str.admin.address;
                percent = 251n;
            } : fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdatePrimaryFee - Greater than 25 : This test should fail"
    |   Fail (Rejected (err, _)) ->  (
        let () = assert_with_error ( Test.michelson_equal err (Test.eval "PERCENTAGE_MUST_BE_MAXIUM_25_PERCENT") ) "Admin -> UpdatePrimaryFee - Greater than 25 : Should not work if percentage is greater than 50" in
        "Passed"
    )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if not admin
let test_primary_update_fee_no_admin = 
    let _, contract_add = get_fixed_price_contract (false) in
    let contract = Test.to_contract contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdatePrimaryFee ({
                address = no_admin_addr;
                percent = 4n;
            } : fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdatePrimaryFee - Wrong admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> UpdatePrimaryFee - Wrong admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"
    
// Should fail if amount passed as parameter
let test_primary_update_fee_with_amount = 
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdatePrimaryFee ({
                address = init_str.admin.address;
                percent = 4n;
            } : fee_data ))) 1tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdatePrimaryFee - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> UpdatePrimaryFee - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success update fee
let test_secondary_update_fee =
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let current_fee_addr = init_str.admin.address in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let _gas_0 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdateSecondaryFee ({
                address = init_str.admin.address;
                percent = 4n;
            } : fee_data ))) 0tez in
    
    let new_fee_percent_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_percent_str.fee_secondary.percent = 4n) "Admin -> UpdateSecondaryFee - Success (percentage): Wrong fee percent after update" in

    // Test change fee address
    let new_fee_addr = Test.nth_bootstrap_account 1 in
    let _gas_1 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdateSecondaryFee ({
                address = new_fee_addr;
                percent = 4n;
            } : fee_data ))) 0tez in

    let new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_addr_str.fee_secondary.address = new_fee_addr) "Admin -> UpdateSecondaryFee - Success (address) : Wrong fee address after update" in

    // Test change fee address & percentage
    let _gas_2 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdateSecondaryFee ({
                address = current_fee_addr;
                percent = 5n;
            } : fee_data ))) 0tez in

    let second_new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (second_new_fee_addr_str.fee_secondary.address = current_fee_addr) "Admin -> UpdateSecondaryFee - Success (address & percentage) : Wrong fee address after update" in
    let () = assert_with_error (second_new_fee_addr_str.fee_secondary.percent = 5n) "Admin -> UpdateSecondaryFee - Success (address & percentage) : Wrong fee percent after update" in
    "Passed"

// Should fail if percentage is greater than 50
let test_secondary_update_fee_negative_value =
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let current_fee_addr = init_str.admin.address in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdateSecondaryFee ({
                address = init_str.admin.address;
                percent = 251n;
            } : fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdateSecondaryFee - Greater than 25 : This test should fail"
    |   Fail (Rejected (err, _)) ->  (
        let () = assert_with_error ( Test.michelson_equal err (Test.eval "PERCENTAGE_MUST_BE_MAXIUM_25_PERCENT") ) "Admin -> UpdateSecondaryFee - Greater than 25 : Should not work if percentage is greater than 50" in
        "Passed"
    )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if not admin
let test_secondary_update_fee_no_admin = 
    let _, contract_add = get_fixed_price_contract (false) in
    let contract = Test.to_contract contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdateSecondaryFee ({
                address = no_admin_addr;
                percent = 4n;
            } : fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdateSecondaryFee - Wrong admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> UpdateSecondaryFee - Wrong admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"
    
// Should fail if amount passed as parameter
let test_secondary_update_fee_with_amount = 
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdateSecondaryFee ({
                address = init_str.admin.address;
                percent = 4n;
            } : fee_data ))) 1tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdateSecondaryFee - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> UpdateSecondaryFee - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// -- UPDATE PUBLIC KEY --

// Success update public_key
let test_update_public_key = 
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let new_account : (string * key) = Test.new_account () in
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (UpdatePublicKey (new_account.1))) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (Test.eval(new_str.admin.pb_key) = Test.eval(new_account.1)) "Admin -> UpdatePublicKey - Success : Wrong key after update" in
    "Passed"

// Should fail if not admin
let test_update_public_key_not_admin = 
    let _, contract_add = get_fixed_price_contract (false) in
    
    let new_account : (string * key) = Test.new_account () in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let contract = Test.to_contract contract_add in
    
    let result = Test.transfer_to_contract contract (Admin (UpdatePublicKey (new_account.1))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdatePublicKey - Wrong admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> UpdatePublicKey - Wrong admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Should fail if amount passed as parameter
let test_update_public_key_with_amount =
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let new_account : (string * key) = Test.new_account () in
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract (Admin (UpdatePublicKey (new_account.1))) 1tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdatePublicKey - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> UpdatePublicKey - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// -- CONTRACT WILL UPDATE --

// Success
let test_contract_will_update =
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in
    let _gas = Test.transfer_to_contract_exn contract (Admin  (ContractWillUpdate (true))) 0tez in    

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.contract_will_update = true) "Admin -> ContractWillUpdate - True : Should be true" in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (ContractWillUpdate (false))) 0tez in    

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.contract_will_update = false) "Admin -> ContractWillUpdate - True : Should be true" in
    "Passed"

// Should fail if not admin
let test_contract_will_update_not_admin =
    let _, contract_add = get_fixed_price_contract (false) in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  (ContractWillUpdate (true))) 0tez in    

    match result with
        Success _gas -> failwith "Admin -> ContractWillUpdate - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> ContractWillUpdate - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount passed as parameter
let test_contract_will_update_with_amount =
    let _, contract_add = get_fixed_price_contract (false) in
    let init_str = Test.get_storage contract_add in
    
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract (Admin  (ContractWillUpdate (true))) 1tez in    

    match result with
        Success _gas -> failwith "Admin -> ContractWillUpdate - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> ContractWillUpdate - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    