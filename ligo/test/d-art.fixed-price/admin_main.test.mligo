#import "../../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../../d-art.fixed-price/fixed_price_main.mligo" "FP_M"

// TEST FILE FOR ADMIN ENTRYPOINTS

// Create initial storage
let get_initial_storage () = 
    let () = Test.reset_state 8n ([]: tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let admin_2 = Test.nth_bootstrap_account 2 in

    let account : (string * key) = Test.new_account () in
    let signed_ms = (Big_map.empty : FP_I.signed_message_used) in
    
    let admin_str : FP_I.admin_storage = {
        address = admin;
        pb_key = account.1;
        signed_message_used = signed_ms;
        contract_will_update = false;
    } in

    let empty_sales = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_sale) big_map ) in
    let empty_sellers = (Big_map.empty : (address, unit) big_map ) in
    let empty_drops = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (FP_I.fa2_base, unit) big_map) in

    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = empty_drops;
        fa2_sold = empty_dropped;
        fa2_dropped = empty_dropped;
        fee_primary = {
            address = admin;
            percent = 10n;
        };
        fee_secondary = {
            address = admin_2;
            percent = 3n;
        };
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate FP_M.fixed_price_tez_main str 0tez in
    taddr

// -- UPDATE FEE --


// Success update fee
let test_primary_update_fee =
    let contract_add = get_initial_storage () in
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
            } : FP_I.fee_data ))) 0tez in
    
    let new_fee_percent_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_percent_str.fee_primary.percent = 4n) "Admin -> UpdatePrimaryFee - Success (percentage): Wrong fee percent after update" in

    // Test change fee address
    let new_fee_addr = Test.nth_bootstrap_account 1 in
    let _gas_1 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdatePrimaryFee ({
                address = new_fee_addr;
                percent = 4n;
            } : FP_I.fee_data ))) 0tez in

    let new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_addr_str.fee_primary.address = new_fee_addr) "Admin -> UpdatePrimaryFee - Success (address) : Wrong fee address after update" in

    // Test change fee address & percentage
    let _gas_2 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdatePrimaryFee ({
                address = current_fee_addr;
                percent = 5n;
            } : FP_I.fee_data ))) 0tez in

    let second_new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (second_new_fee_addr_str.fee_primary.address = current_fee_addr) "Admin -> UpdatePrimaryFee - Success (address & percentage) : Wrong fee address after update" in
    let () = assert_with_error (second_new_fee_addr_str.fee_primary.percent = 5n) "Admin -> UpdatePrimaryFee - Success (address & percentage) : Wrong fee percent after update" in
    "Passed"

// Should fail if percentage is greater than 50
let test_primary_update_fee_negative_value =
    let contract_add = get_initial_storage () in
    let init_str = Test.get_storage contract_add in
    
    let current_fee_addr = init_str.admin.address in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdatePrimaryFee ({
                address = init_str.admin.address;
                percent = 51n;
            } : FP_I.fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdatePrimaryFee - Greater than 50 : This test should fail"
    |   Fail (Rejected (err, _)) ->  (
        let () = assert_with_error ( Test.michelson_equal err (Test.eval "PERCENTAGE_MUST_BE_MAXIUM_15_PERCENT") ) "Admin -> UpdatePrimaryFee - Greater than 50 : Should not work if percentage is greater than 50" in
        "Passed"
    )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if not admin
let test_primary_update_fee_no_admin = 
    let contract_add = get_initial_storage () in
    let contract = Test.to_contract contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdatePrimaryFee ({
                address = no_admin_addr;
                percent = 4n;
            } : FP_I.fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdatePrimaryFee - Wrong admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> UpdatePrimaryFee - Wrong admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"
    
// Should fail if amount passed as parameter
let test_primary_update_fee_with_amount = 
    let contract_add = get_initial_storage () in
    let init_str = Test.get_storage contract_add in
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdatePrimaryFee ({
                address = init_str.admin.address;
                percent = 4n;
            } : FP_I.fee_data ))) 1tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdatePrimaryFee - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> UpdatePrimaryFee - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    



// Success update fee
let test_secondary_update_fee =
    let contract_add = get_initial_storage () in
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
            } : FP_I.fee_data ))) 0tez in
    
    let new_fee_percent_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_percent_str.fee_secondary.percent = 4n) "Admin -> UpdateSecondaryFee - Success (percentage): Wrong fee percent after update" in

    // Test change fee address
    let new_fee_addr = Test.nth_bootstrap_account 1 in
    let _gas_1 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdateSecondaryFee ({
                address = new_fee_addr;
                percent = 4n;
            } : FP_I.fee_data ))) 0tez in

    let new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (new_fee_addr_str.fee_secondary.address = new_fee_addr) "Admin -> UpdateSecondaryFee - Success (address) : Wrong fee address after update" in

    // Test change fee address & percentage
    let _gas_2 = Test.transfer_to_contract_exn contract
        (Admin
            (UpdateSecondaryFee ({
                address = current_fee_addr;
                percent = 5n;
            } : FP_I.fee_data ))) 0tez in

    let second_new_fee_addr_str = Test.get_storage contract_add in
    let () = assert_with_error (second_new_fee_addr_str.fee_secondary.address = current_fee_addr) "Admin -> UpdateSecondaryFee - Success (address & percentage) : Wrong fee address after update" in
    let () = assert_with_error (second_new_fee_addr_str.fee_secondary.percent = 5n) "Admin -> UpdateSecondaryFee - Success (address & percentage) : Wrong fee percent after update" in
    "Passed"

// Should fail if percentage is greater than 50
let test_secondary_update_fee_negative_value =
    let contract_add = get_initial_storage () in
    let init_str = Test.get_storage contract_add in
    
    let current_fee_addr = init_str.admin.address in

    let contract = Test.to_contract contract_add in
    let () = Test.set_source current_fee_addr in
    
    // Test change fee percentage
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdateSecondaryFee ({
                address = init_str.admin.address;
                percent = 51n;
            } : FP_I.fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdateSecondaryFee - Greater than 50 : This test should fail"
    |   Fail (Rejected (err, _)) ->  (
        let () = assert_with_error ( Test.michelson_equal err (Test.eval "PERCENTAGE_MUST_BE_MAXIUM_15_PERCENT") ) "Admin -> UpdateSecondaryFee - Greater than 50 : Should not work if percentage is greater than 50" in
        "Passed"
    )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if not admin
let test_secondary_update_fee_no_admin = 
    let contract_add = get_initial_storage () in
    let contract = Test.to_contract contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdateSecondaryFee ({
                address = no_admin_addr;
                percent = 4n;
            } : FP_I.fee_data ))) 0tez in
    
    match result with
        Success _gas -> failwith "Admin -> UpdateSecondaryFee - Wrong admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> UpdateSecondaryFee - Wrong admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"
    
// Should fail if amount passed as parameter
let test_secondary_update_fee_with_amount = 
    let contract_add = get_initial_storage () in
    let init_str = Test.get_storage contract_add in
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in
    // Test change fee value
    let result = Test.transfer_to_contract contract
        (Admin
            (UpdateSecondaryFee ({
                address = init_str.admin.address;
                percent = 4n;
            } : FP_I.fee_data ))) 1tez in
    
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
    let contract_add = get_initial_storage () in
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
    let contract_add = get_initial_storage () in
    let init_str = Test.get_storage contract_add in
    
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
    let contract_add = get_initial_storage () in
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
    let contract_add = get_initial_storage () in
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
    let contract_add = get_initial_storage () in
    let init_str = Test.get_storage contract_add in
    
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
    let contract_add = get_initial_storage () in
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