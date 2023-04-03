#import "storage.test.mligo" "FA2_STR"
#import "balance_of_callback_contract.mligo" "CALB"
#import "../../there.fa2-editions/interface.mligo" "FA2_I"
#include "../../there.fa2-editions/multi_nft_token_editions.mligo"

// -- Balance of --

// Fail no amount
let test_balance_of_empty_no_amount = 
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let callback_addr, _, _ = Test.originate CALB.main ([] : nat list) 0tez in
    let callback_contract = Test.to_contract callback_addr in

    let balance_of_requests = ({
        requests = ([] : FA2_I.balance_of_request list);
        callback = callback_contract;
    } : FA2_I.balance_of_param) in

    let result = Test.transfer_to_contract contract  (FA2 ((Balance_of balance_of_requests) : fa2_entry_points) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "FA2 -> Balance_of - No amount : This test should fail "
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "FA2 -> Balance_of - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Fail token undefined
let test_balance_of_empty_no_amount = 
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let callback_addr, _, _ = Test.originate CALB.main ([] : nat list) 0tez in
    let callback_contract = Test.to_contract callback_addr in

    let balance_of_requests = ({
        requests = ([{
            owner = owner1;
            token_id = 99999n;
        }] : FA2_I.balance_of_request list);
        callback = callback_contract;
    } : FA2_I.balance_of_param) in

    let result = Test.transfer_to_contract contract  (FA2 ((Balance_of balance_of_requests) : fa2_entry_points) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "FA2 -> Balance_of - Token undefined : This test should fail "
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_TOKEN_UNDEFINED") ) "FA2 -> Balance_of - Token undefined : Should not work if token is undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success empty balance
let test_balance_of_empty = 
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let callback_addr, _, _ = Test.originate CALB.main ([] : nat list) 0tez in
    let callback_contract = Test.to_contract callback_addr in

    let balance_of_requests = ({
        requests = ([] : FA2_I.balance_of_request list);
        callback = callback_contract;
    } : FA2_I.balance_of_param) in

    let _gas = Test.transfer_to_contract_exn contract  (FA2 ((Balance_of balance_of_requests) : fa2_entry_points) : editions_entrypoints) 0tez in

    let callback_strg = Test.get_storage callback_addr in

    let () = assert_with_error (callback_strg = ([] : nat list)) "FA2 -> Balance_of - Success empty : Callback contract storage should be empty " in
    "Passed"

// Success no balance (interpreted as 0) and duplicate balance of request
let test_balance_of_request_no_token_and_duplicate = 
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let callback_addr, _, _ = Test.originate CALB.main ([] : nat list) 0tez in
    let callback_contract = Test.to_contract callback_addr in

    let balance_of_requests = ({
        requests = ([{
            owner = owner1;
            token_id = 1n;
        }; {
            owner = owner1;
            token_id = 1n;
        }; {
            owner = owner1;
            token_id = 2n;
        }] : FA2_I.balance_of_request list);
        callback = callback_contract;
    } : FA2_I.balance_of_param) in

    let _gas = Test.transfer_to_contract_exn contract  (FA2 ((Balance_of balance_of_requests) : fa2_entry_points) : editions_entrypoints) 0tez in

    let callback_strg = Test.get_storage callback_addr in

    let () = assert_with_error (callback_strg = [1n; 1n; 0n]) "FA2 -> Balance_of - Success no balance and duplicate req : Callback contract should contain 0n for token with no balance and not de duplicate the response " in
    "Passed"


// -- Transfer --

// Fail if token undefined
let test_transfer_token_undefined = 
    let contract_add, admin, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 999n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer)
    ] : FA2_I.transfer list ) in

    let result = Test.transfer_to_contract contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "FA2 -> Transfer - Token undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_TOKEN_UNDEFINED") ) "FA2 -> Transfer - Token undefined : Should not work if token is undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"  

// Fail if one transfer does not work in the batch
let test_transfer_batch_transaction_fail_if_one_does = 
    let contract_add, admin, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in
    let () = Test.set_source owner1 in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 1n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 4n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 999n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
    ] : FA2_I.transfer list ) in

    let result = Test.transfer_to_contract contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "FA2 -> Transfer - Batch fail transfer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let new_strg = Test.get_storage contract_add in
            let () = match Big_map.find_opt 1n new_strg.assets.ledger with
                    Some add -> assert_with_error ( add = owner1 ) "FA2 -> Transfer - Batch fail transfer : Token should not be transfered"
                |   None -> (failwith "FA2 -> Transfer - Batch fail transfer : Token should still exist")
            in
            let () = match Big_map.find_opt 4n new_strg.assets.ledger with
                    Some add -> assert_with_error ( add = owner1 ) "FA2 -> Transfer - Batch fail transfer : Token should not be transfered"
                |   None -> failwith "FA2 -> Transfer - Batch fail transfer : Token should still exist"
            in
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_TOKEN_UNDEFINED") ) "FA2 -> Transfer - Batch fail transfer : Should not work if one transfer fail" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"  

// Fail if not operator/owner
let test_transfer_not_operator_not_owner =
    let contract_add, admin, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in
    let () = Test.set_source admin in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 1n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
    ] : FA2_I.transfer list ) in

    let result = Test.transfer_to_contract contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "FA2 -> Transfer - Not operator : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let new_strg = Test.get_storage contract_add in
            let () = match Big_map.find_opt 1n new_strg.assets.ledger with
                    Some add -> assert_with_error ( add = owner1 ) "FA2 -> Transfer - Not operator : Token should not be transfered"
                |   None -> (failwith "FA2 -> Transfer - Not operator : Token should still exist")
            in
            
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_NOT_OPERATOR") ) "FA2 -> Transfer - Not operator : Should not work if not operator" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"  

// Fail if insufficient balance
let test_transfer_insufficient_balance =
    let contract_add, admin, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in
    let () = Test.set_source owner1 in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 2n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
    ] : FA2_I.transfer list ) in

    let result = Test.transfer_to_contract contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "FA2 -> Transfer - Batch fail transfer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_INSUFFICIENT_BALANCE") ) "FA2 -> Transfer - Batch fail transfer : Should not work if insufficient_balance" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"  

// Fail no amount
let test_transfer_no_amount =
    let contract_add, admin, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in
    let () = Test.set_source owner1 in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 1n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
    ] : FA2_I.transfer list ) in

    let result = Test.transfer_to_contract contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "FA2 -> Transfer - Batch fail transfer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "FA2 -> Transfer - Batch fail transfer : Should not work if insufficient_balance" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"  


// Success if operator
let test_transfer_is_operator =
    let contract_add, admin, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let operator1 = Test.nth_bootstrap_account 4 in
    let () = Test.set_source operator1 in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 1n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
    ] : FA2_I.transfer list ) in

    let _gas = Test.transfer_to_contract_exn contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 0tez in

    let new_strg = Test.get_storage contract_add in

    match Big_map.find_opt 1n new_strg.assets.ledger with
        Some add -> (
            let () = assert_with_error ( add = admin ) "FA2 -> Transfer - Batch fail transfer : Ownership should have change" in 
            "Passed"
        )
    |   None -> failwith "FA2 -> Transfer - Operator transfer success : Token should not be burnt"  
    
    
// Success if owner
let test_transfer_is_owner =
    let contract_add, admin, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 1n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
    ] : FA2_I.transfer list ) in

    let _gas = Test.transfer_to_contract_exn contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 0tez in

    let new_strg = Test.get_storage contract_add in

    match Big_map.find_opt 1n new_strg.assets.ledger with
        Some add -> (
            let () = assert_with_error ( add = admin ) "FA2 -> Transfer - Owner transfer success : Ownership should have change" in 
            "Passed"
        )
    |   None -> failwith "FA2 -> Transfer - Owner transfer success : Token should not be burnt"  

// Success from_ to_ is the same address
let test_transfer_sender_is_receiver =
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = owner1; token_id = 1n; amount = 1n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
    ] : FA2_I.transfer list ) in

    let _gas = Test.transfer_to_contract_exn contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 0tez in

    let new_strg = Test.get_storage contract_add in

    match Big_map.find_opt 1n new_strg.assets.ledger with
        Some add -> (
            let () = assert_with_error ( add = owner1 ) "FA2 -> Transfer - Owner is receiver : Ownership should NOT have change" in 
            "Passed"
        )
    |   None -> failwith "FA2 -> Transfer - Owner is receiver : Token should not be burnt"  

// Success if amount = 0n
let test_transfer_null_token_amount =
    let contract_add, admin, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let transfer_requests = ([
        ({from_ = owner1; txs = ([{to_ = admin; token_id = 1n; amount = 0n};] : FA2_I.transfer_destination list)} : FA2_I.transfer);
    ] : FA2_I.transfer list ) in

    let _gas = Test.transfer_to_contract_exn contract (FA2 ((Transfer transfer_requests ) : fa2_entry_points) : editions_entrypoints) 0tez in

    let new_strg = Test.get_storage contract_add in

    match Big_map.find_opt 1n new_strg.assets.ledger with
        Some add -> (
            let () = assert_with_error ( add = owner1 ) "FA2 -> Transfer - Token amount 0 : Ownership should NOT have change" in 
            "Passed"
        )
    |   None -> failwith "FA2 -> Transfer - Token amount 0 : Token should not be burnt"  
