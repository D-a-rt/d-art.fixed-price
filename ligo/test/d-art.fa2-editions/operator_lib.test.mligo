#import "storage.test.mligo" "FA2_STR"

// -- Add operator -- 

// Fail if not owner
let test_add_operator_not_owner =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let owner2 = Test.nth_bootstrap_account 2 in

    let result = Test.transfer_to_contract contract 
        (FA2 
            (Update_operators ([
                (Add_operator ({
                    owner = owner2;
                    operator = owner1;
                    token_id = 1n;
                }))
            ]))) 0tez 
    in

    match result with
        Success _gas -> failwith "FA2 -> Update_operators -> Add_operator - Not owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_NOT_OWNER") ) "FA2 -> Update_operators -> Add_operator - Not owner : Should not work if not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_add_operator_no_amount =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let owner2 = Test.nth_bootstrap_account 2 in

    let result = Test.transfer_to_contract contract 
        (FA2 
            (Update_operators ([
                (Add_operator ({
                    owner = owner2;
                    operator = owner1;
                    token_id = 1n;
                }))
            ]))) 1tez 
    in

    match result with
        Success _gas -> failwith "FA2 -> Update_operators -> Add_operator - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "FA2 -> Update_operators -> Add_operator - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_add_operator =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let owner2 = Test.nth_bootstrap_account 2 in

    let _gas = Test.transfer_to_contract_exn contract 
        (FA2 
            (Update_operators ([
                (Add_operator ({
                    owner = owner1;
                    operator = owner2;
                    token_id = 1n;
                }))
            ]))) 0tez 
    in

    let new_str = Test.get_storage contract_add in
    match Big_map.find_opt ((owner1, (owner2, 1n))) new_str.assets.operators with
            Some operator -> "Passed"
        |   None -> "FA2 -> Update_operators -> Add_operator - Success : This test should pass"

// -- Remove operator --

// Fail if not owner
let test_remove_operator_not_owner =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let owner2 = Test.nth_bootstrap_account 2 in

    let result = Test.transfer_to_contract contract 
        (FA2 
            (Update_operators ([
                (Remove_operator ({
                    owner = owner2;
                    operator = owner1;
                    token_id = 1n;
                }))
            ]))) 0tez 
    in

    match result with
        Success _gas -> failwith "FA2 -> Update_operators -> Remove_operator - Not owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_NOT_OWNER") ) "FA2 -> Update_operators -> Remove_operator - Not owner : Should not work if not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_remove_operator_no_amount =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let owner2 = Test.nth_bootstrap_account 2 in

    let result = Test.transfer_to_contract contract 
        (FA2 
            (Update_operators ([
                (Remove_operator ({
                    owner = owner2;
                    operator = owner1;
                    token_id = 1n;
                }))
            ]))) 1tez 
    in

    match result with
        Success _gas -> failwith "FA2 -> Update_operators -> Remove_operator - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "FA2 -> Update_operators -> Remove_operator - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_remove_operator =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let owner2 = Test.nth_bootstrap_account 2 in

    let _gas = Test.transfer_to_contract_exn contract 
        (FA2 
            (Update_operators ([
                (Remove_operator ({
                    owner = owner1;
                    operator = owner2;
                    token_id = 1n;
                }))
            ]))) 0tez 
    in

    let new_str = Test.get_storage contract_add in
    match Big_map.find_opt ((owner1, (owner2, 1n))) new_str.assets.operators with
            Some operator -> "FA2 -> Update_operators -> Remove_operator - Success : This test should fail" 
        |   None -> "Passed"
