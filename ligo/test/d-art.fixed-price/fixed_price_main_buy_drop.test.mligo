#include "storage.test.mligo"

    
// Fail if wrong price
let test_buy_drop_token_wrong_price =
    let _, contract_tadd, edition_contract_add, _, admin = get_fixed_price_contract (false) in
    let contract = Test.to_contract contract_tadd in
    
    let () = Test.set_source admin in
    
    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let expected_time_result_three = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_drops ({
            drop_infos = [({
                commodity = (Tez (150000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract_add : address);
                    id = 0n 
                };
            } : drop_info );]
        } : drop_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract_add: address);
            } : fa2_base);
            seller = admin;
            receiver = no_admin_addr;
            referrer = (None : address option);
        })) 100mutez
    in

    match result with
        Success _gas -> failwith "Buy_dropped_token - Wrong price specified : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WRONG_PRICE_SPECIFIED") ) "Buy_dropped_token - Wrong price specified : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if drop date not met
let test_buy_drop_token_drop_date_not_met =
    let _, contract_tadd, edition_contract_add, _, admin = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    
    let contract = Test.to_contract contract_tadd in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let expected_time_result_three = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_drops ({
            drop_infos = [({
                commodity = (Tez (150000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract_add : address);
                    id = 0n 
                };
            } : drop_info );]
        } : drop_configuration)) 0tez
    in


    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract_add: address);
            } : fa2_base);
            seller = admin;
            receiver = no_admin_addr;
            referrer = (None : address option);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_dropped_token - Drop date not met : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_DATE_NOT_MET") ) "Buy_dropped_token - Drop date not met : Should fail if drop date not met" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if token not in drop
let test_buy_drop_token_not_dropped =
    let _, contract_tadd, edition_contract_add, _, admin = get_fixed_price_contract (false) in
        
    let contract = Test.to_contract contract_tadd in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract_add: address);
            } : fa2_base);
            seller = admin;
            receiver = no_admin_addr;
            referrer = (None : address option);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_dropped_token - Token is not dropped : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_DROPPED") ) "Buy_dropped_token - Token is not dropped : Should fail if drop date not met" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if buyer is seller
let test_buy_drop_token_buyer_is_seller =
    let _, contract_tadd, edition_contract_add, _, admin = get_fixed_price_contract (false) in
    
    let contract = Test.to_contract contract_tadd in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract
         (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract_add: address);
            } : fa2_base);
            seller = admin;
            receiver = admin;
            referrer = (None : address option);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is buyer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SELLER_NOT_AUTHORIZED") ) "Buy_fixed_price_token - Seller is buyer : Should not work if seller is buyer" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
