#include "storage.test.mligo"
// -- CREATE DROPS --

// Success
let test_create_drops =
    let _, contract_t_add, fa2_add, _ , _ = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in

    let token_minter = Test.nth_bootstrap_account 0 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + four_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (150000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : drop_info ); ({
                drop_date = expected_time_result_four;
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = (fa2_add : address);
                    id = 1n
                };
            } : drop_info)]
        } : drop_configuration)) 0tez
    in
    
    let new_str = Test.get_storage contract_t_add in
    match result with
          Success _gas -> (
              // Check message is well saved
                let () = match Big_map.find_opt ("54657374206d657373616765207465746574657465" : bytes) new_str.admin.signed_message_used with
                            Some _ -> unit
                        |   None -> (failwith "Create_drops - Success : This test should pass (err: Signed message not saved)" : unit)
                in
                // Check first sale if well saved
                let first_drop_key : fa2_base * address = (
                    {
                        address = ( fa2_add : address);
                        id = 0n
                    },
                    token_minter
                 ) in
                let () = match Big_map.find_opt first_drop_key new_str.drops with
                        Some fixed_drop_saved -> (
                            let () = assert_with_error (fixed_drop_saved.commodity = (Tez (150000mutez))) "Create_drops - Success : This test should pass (err: First sale wrong price saved)" in
                            assert_with_error (fixed_drop_saved.drop_date = expected_time_result_three) "Create_drops - Success : This test should pass (err: First sale wrong date saved)"
                        )
                    |   None -> (failwith "Create_drops - Success : This test should pass (err: First drop not saved)" : unit)
                in
                // Check second sale if well saved
                let second_drop_key : fa2_base * address = (
                    {
                        address = ( fa2_add : address);
                        id = 1n
                    },
                    token_minter
                 ) in
                let () = match Big_map.find_opt second_drop_key new_str.drops with
                        Some fixed_drop_saved -> (
                            let () = assert_with_error (fixed_drop_saved.commodity = (Tez (100000mutez))) "Create_drops - Success : This test should pass (err: Second drop wrong price saved)" in
                            assert_with_error (fixed_drop_saved.drop_date = expected_time_result_four) "Create_drops - Success : This test should pass (err: Second drop wrong date saved)"
                        )
                    |   None -> (failwith "Create_drops - Success : This test should pass (err: Second drop not saved)" : unit)
                in
                "Passed"
          )
        |   Fail (Rejected (_err, _)) ->  "Create_drops - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    
    
// Should fail if amount specified
let test_create_drops_with_amount = 
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + four_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (150000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : drop_info ); ({
                drop_date = expected_time_result_four;
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : drop_info)]
        } : drop_configuration)) 1tez
    in
    
    match result with
        Success _gas -> failwith "Create_drops - No amount : This test should fail (err: Amount specified for create_drops entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Create_drops - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if contract will be deprecated
let test_create_drops_deprecated = 
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (true, false, false, Tezos.get_now() + 28800) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + four_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (150000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : drop_info ); ({
                drop_date = expected_time_result_four;
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : drop_info)]
        } : drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Will deprecate : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WILL_BE_DEPRECATED") ) "Create_drops - Will deprecate : Should not work if contract will deprecate" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
    
// Should fail if price do not meet minimum price
let test_create_drops_price_to_small_first_el =
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + four_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (1000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : drop_info ); ({
                drop_date = expected_time_result_four;
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : drop_info)]
        } : drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PRICE_SHOULD_BE_MINIMUM_0.1tez") ) "Create_drops - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price do not meet minimum price
let test_create_drops_price_to_small_second_el = 
    let _, contract_t_add, fa2_add, _ , _ = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in
    
    let token_minter = Test.nth_bootstrap_account 0 in
    
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + four_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : drop_info ); ({
                drop_date = expected_time_result_four;
                commodity = (Tez (1000mutez));
                fa2_token = {
                    address = (fa2_add : address);
                    id = 1n
                };
            } : drop_info)]
        } : drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PRICE_SHOULD_BE_MINIMUM_0.1tez") ) "Create_drops - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if already in drop
let test_create_drops_already_in_drop = 
    let _, contract_t_add, fa2_add, _ , _ = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in
    
    let token_minter = Test.nth_bootstrap_account 0 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + four_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : drop_info ); ({
                drop_date = expected_time_result_four;
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n
                };
            } : drop_info)]
        } : drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Already in drop : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_DROPED") ) "Create_drops - Already in drop : Should not work if token is already in drop" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if already dropped
let test_create_drops_already_dropped =
    let _, contract_t_add, _, _ , _ = get_fixed_price_contract_drop (false, true, false, Tezos.get_now() + 28800) in
    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    
    let expected_time_result_three = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : drop_info )]
        } : drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Already dropped : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_DROPED") ) "Create_drops - Already dropped : Should not work if token is already in drop" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Should fail if wrong signature
let test_create_drops_wrong_signature = 
    let _, contract_t_add, fa2_add, _ , _ = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    
    let expected_time_result_three = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d65737361676520746573742077726f6e67" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : drop_info )]
        } : drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Wrong signature : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "Create_drops - Wrong signature : Should not work if signature is not correct" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if signature already used
let test_create_drops_already_used_signature = 
    let _, contract_t_add, fa2_add, _ , _ = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in
    
    let token_minter = Test.nth_bootstrap_account 0 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + four_days in

    let _gas2 = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 1n 
                };
            } : drop_info )]
        } : drop_configuration)) 0tez
    in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_four;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : drop_info )]
        } : drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Already used signature : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "Create_drops - Already used signature : Should not work if signature is already used" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if wrong drop date
let test_create_drops_wrong_drop_date = 
    let _, contract_t_add, fa2_add, _ , _ = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_t_add in

    let now : timestamp = Tezos.get_now() in
    let less_than_a_day : int = 6000 in
    let more_than_a_month : int = 2707200 in
    
    let expected_time_result_less = now + less_than_a_day in
    let expected_time_result_more = now + more_than_a_month in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_less;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 250n 
                };
            } : drop_info )]
        } : drop_configuration)) 0tez
    in

    let () = match result with
            Success _gas -> failwith "Create_drops - To early drop date : This test should fail"
        |   Fail (Rejected (err, _)) ->  assert_with_error ( Test.michelson_equal err (Test.eval "DROP_DATE_MUST_BE_AT_LEAST_IN_A_DAY") ) "Create_drops - To early drop date : Should not work if drop_date is in less than a day"
        |   Fail _ -> failwith "Internal test failure"
    in

    let second_result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_more;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : drop_info )]
        } : drop_configuration)) 0tez
    in

    match second_result with
        Success _gas -> failwith "Create_drops - Drop date to far : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_DATE_MUST_BE_IN_MAXIMUM_ONE_MONTH") ) "Create_drops - Drop date to far : Should not work if drop_date is greater than a month" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if not an authorized drop seller
let test_create_drops_not_authorized_drop_seller = 
    let _, contract_t_add, fa2_add, _ , _ = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 28800) in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    
    let contract = Test.to_contract contract_t_add in
    let now : timestamp = Tezos.get_now() in
    let three_days : int = 253800 in
    let expected_time_result_three = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            drop_infos = [({
                commodity = (Tez (100000mutez));
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : drop_info )]
        } : drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Not authorized to drop : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AUTHORIZED_DROP_SELLER") ) "Create_drops - Not authorized to drop : Should not work if seller is not whitelisted" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// -- REVOKE DROPS --

// Should sucess if token been already revoked before drop date

// Success before drop date and token removed from dropped big_map
let test_revoke_drops_before_drop_date =
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (false, true, true, Tezos.get_now() + 28800) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base )
            ]
        })) 0tez
    in

    let new_str = Test.get_storage contract_t_add in
    match result with
        Success _gas -> (
                // Check if drops is revoked from the currently drops big map
                let first_revoke_sale_key : fa2_base * address = (
                {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                },
                admin
                ) in
                let () = match Big_map.find_opt first_revoke_sale_key new_str.drops with
                        Some _ -> (failwith "Revoke_drops - Success : This test should pass (err: First drop should be deleted)" : unit)
                    |   None -> unit
                in
                // Check if the drop is revoked from the dropped big_map
                let first_revoke_sale_dropped_key : fa2_base = {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                } in
                let () = match Big_map.find_opt first_revoke_sale_dropped_key new_str.fa2_dropped with
                        Some _ -> (failwith "Revoke_drops - Success : This test should pass (err: First drop should be deleted from dropped big_map)" : unit)
                    |   None -> unit
                in
            // Check second sale if well saved
            let second_revoke_sale_key : fa2_base * address = (
                {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                },
                admin
                ) in
            let () = match Big_map.find_opt second_revoke_sale_key new_str.drops with
                    Some _ -> (failwith "Revoke_drops - Success : This test should pass (err: Second drop should be deleted)" : unit)
                |   None -> unit
            in
            // Check if the drop is revoked from the dropped big_map
            let second_revoke_sale_dropped_key : fa2_base = {
                address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n
            } in
            let () = match Big_map.find_opt second_revoke_sale_dropped_key new_str.fa2_dropped with
                    Some _ -> (failwith "Revoke_drops - Success : This test should pass (err: Second drop should be deleted from dropped big_map)" : unit)
                |   None -> unit
            in
            "Passed"
        )
    |   Fail (Rejected (_err, _)) -> "Revoke_drops - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"    

// Success after drop date + 1 day and token stay in dropped big_map
let test_revoke_drops_after_drope_date =
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (false, true, true, Tezos.get_now() - 87800) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base )
            ]
        })) 0tez
    in

    let new_str = Test.get_storage contract_t_add in
    match result with
        Success _gas -> (
                // Check if drops is revoked from the currently drops big map
                let first_revoke_sale_key : fa2_base * address = (
                {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                },
                admin
                ) in
                let () = match Big_map.find_opt first_revoke_sale_key new_str.drops with
                        Some _ -> (failwith "Revoke_drops - Success : This test should pass (err: First drop should be deleted)" : unit)
                    |   None -> unit
                in
                // Check if the drop is revoked from the dropped big_map
                let first_revoke_sale_dropped_key : fa2_base = {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                } in
                let () = match Big_map.find_opt first_revoke_sale_dropped_key new_str.fa2_dropped with
                        Some _ -> unit
                    |   None -> (failwith "Revoke_drops - Success : This test should pass (err: First drop should not be deleted from dropped big_map)" : unit)
                in
            // Check second sale if well saved
            let second_revoke_sale_key : fa2_base * address = (
                {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                },
                admin
                ) in
            let () = match Big_map.find_opt second_revoke_sale_key new_str.drops with
                    Some _ -> (failwith "Revoke_drops - Success : This test should pass (err: Second drop should be deleted)" : unit)
                |   None -> unit
            in
            // Check if the drop is revoked from the dropped big_map
            let second_revoke_sale_dropped_key : fa2_base = {
                address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n
            } in
            let () = match Big_map.find_opt second_revoke_sale_dropped_key new_str.fa2_dropped with
                    Some _ -> unit
                |   None -> (failwith "Revoke_drops - Success : This test should pass (err: Second drop should not be deleted from dropped big_map)" : unit)
            in
            "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Revoke_drops - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount specified
let test_revoke_drops_with_amount =
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (false, true, true, Tezos.get_now() + 22800) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base )
            ]
        })) 1tez
    in

    match result with
        Success _gas -> failwith "Revoke_drops - No amount : This test should fail (err: Amount specified for revoke_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Revoke_drops - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drops not created
let test_revoke_drops_not_created =
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (false, false, false, Tezos.get_now() + 22800) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base )
            ]
        })) 0tez
    in

    match result with
        Success _gas -> failwith "Revoke_drops - Drops are not created : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_DROPPED") ) "Revoke_drops - Drops are not created : Should not work if drop is not created" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sender not owner
let test_revoke_drops_sender_not_owner =
    let _, contract_t_add, _, _ , _ = get_fixed_price_contract_drop (false, true, true, Tezos.get_now() + 22800) in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_t_add in
    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base )
            ]
        })) 0tez
    in

    match result with
        Success _gas -> failwith "Revoke_drops - Drops sender not owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_DROPPED") ) "Revoke_drops - Drops sender not owner : Should not work if sender is not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drop_date in less than 6 hours
let test_revoke_drops_less_than_6_hours_before_drop_date =
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (false, true, true, Tezos.get_now() + 20800) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base )
            ]
        })) 0tez
    in

    match result with
        Success _gas -> failwith "Revoke_drops - Drop date in less than 6 hours : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_CANNOT_BE_REVOKED") ) "Revoke_drops - Drop date in less than 6 hours : Should not work if drop date less than 6 hours" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drop_date < now < 1 day 
let test_revoke_drops_between_drop_date_and_one_day =
    let _, contract_t_add, _, _ , admin = get_fixed_price_contract_drop (false, true, true, Tezos.get_now() - 84400) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: fa2_base )
            ]
        })) 0tez
    in

    match result with
        Success _gas -> failwith "Revoke_drops - Drop date was in less than a day : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_CANNOT_BE_REVOKED") ) "Revoke_drops - Drop date was in less than a day : Should not work if drop date was in less than a day" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

