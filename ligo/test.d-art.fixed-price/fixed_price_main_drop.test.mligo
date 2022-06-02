#import "../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../d-art.fixed-price/fixed_price_main.mligo" "FP_M"

// Create initial storage
let get_initial_storage (will_update, isDropped, isInDrops, drop_date : bool * bool * bool * timestamp) = 
    let admin = Test.nth_bootstrap_account 0 in
    let signed_ms = (Big_map.empty : FP_I.signed_message_used) in
    
    let admin_str : FP_I.admin_storage = {
        address = admin;
        pb_key = ("edpkttsmzdmXenJw1s5VoXfrBHdo2f3WX9J3cyYByMj2cQSqzRR9uT" : key);
        signed_message_used = signed_ms;
        contract_will_update = will_update;
    } in

    let empty_sales = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_sale) big_map ) in
    let empty_sellers = (Big_map.empty : (address, unit) big_map ) in
    let empty_drops = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (FP_I.fa2_base, unit) big_map) in
    let dropped : (FP_I.fa2_base, unit ) big_map = Big_map.literal ([
                (({
                    id = 0n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } : FP_I.fa2_base), ());
            ]) in

    let fa2_b_1 : FP_I.fa2_base = {
                    id = 0n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } in
    
    let fa2_b_2 : FP_I.fa2_base = {
                    id = 1n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } in

    let drops_str : FP_I.drops_storage = Big_map.literal ([
        ((fa2_b_1, admin),
            ({
                price = 1000000mutez;
                drop_date = drop_date;
            })
        );
        ((fa2_b_2, admin),
            ({
                price = 1000000mutez;
                drop_date = drop_date;
            })
        );
    ]) in

    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        authorized_drops_seller = empty_sellers;
        drops = empty_drops;
        fa2_dropped = empty_dropped;
        fee = {
            address = admin;
            percent = 3n;
        }
    } in

    if isDropped
    then (
        if isInDrops
        then (
             let str = { str with drops = drops_str; fa2_dropped = dropped } in
            let taddr, _, _ = Test.originate FP_M.fixed_price_tez_main str 0tez in
            taddr
        )
        else (
            let str = { str with fa2_dropped = dropped } in
            let taddr, _, _ = Test.originate FP_M.fixed_price_tez_main str 0tez in
            taddr
        )
    )
    else (
        if isInDrops
        then (
             let str = { str with drops = drops_str } in
            let taddr, _, _ = Test.originate FP_M.fixed_price_tez_main str 0tez in
            taddr
        )
        else (
            let taddr, _, _ = Test.originate FP_M.fixed_price_tez_main str 0tez in
            taddr

        )
    )


// -- CREATE DROPS --

// Success
let test_create_drops =
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 150000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.drop_info)]
        } : FP_I.drop_configuration)) 0tez
    in
    
    let new_str = Test.get_storage contract_add in
    match result with
          Success _gas -> (
              // Check message is well saved
                let () = match Big_map.find_opt ("54657374206d657373616765207465746574657465" : bytes) new_str.admin.signed_message_used with
                            Some _ -> unit
                        |   None -> (failwith "CreateDrops - Success : This test should pass (err: Signed message not saved)" : unit)
                in
                // Check first sale if well saved
                let first_drop_key : FP_I.fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 0n
                    },
                    init_str.admin.address
                 ) in
                let () = match Big_map.find_opt first_drop_key new_str.drops with
                        Some fixed_drop_saved -> (
                            let () = assert_with_error (fixed_drop_saved.price = 150000mutez) "CreateDrops - Success : This test should pass (err: First sale wrong price saved)" in
                            assert_with_error (fixed_drop_saved.drop_date = expected_time_result_three) "CreateDrops - Success : This test should pass (err: First sale wrong date saved)"
                        )
                    |   None -> (failwith "CreateDrops - Success : This test should pass (err: First drop not saved)" : unit)
                in
                // Check second sale if well saved
                let second_drop_key : FP_I.fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 1n
                    },
                    init_str.admin.address
                 ) in
                let () = match Big_map.find_opt second_drop_key new_str.drops with
                        Some fixed_drop_saved -> (
                            let () = assert_with_error (fixed_drop_saved.price = 100000mutez) "CreateDrops - Success : This test should pass (err: Second drop wrong price saved)" in
                            assert_with_error (fixed_drop_saved.drop_date = expected_time_result_four) "CreateDrops - Success : This test should pass (err: Second drop wrong date saved)"
                        )
                    |   None -> (failwith "CreateDrops - Success : This test should pass (err: Second drop not saved)" : unit)
                in
                "Passed"
          )
        |   Fail (Rejected (err, _)) ->  "CreateDrops - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    
    
// Should fail if amount specified
let test_create_drops_with_amount = 
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 150000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.drop_info)]
        } : FP_I.drop_configuration)) 1tez
    in
    
    match result with
        Success _gas -> failwith "CreateDrops - No amount : This test should fail (err: Amount specified for create_drops entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "CreateDrops - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if contract will be deprecated
let test_create_drops_deprecated = 
    let contract_add = get_initial_storage (true, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 150000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.drop_info)]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateDrops - Will deprecate : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WILL_BE_DEPRECATED") ) "CreateDrops - Will deprecate : Should not work if contract will deprecate" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
    
// Should fail if price do not meet minimum price
let test_create_drops_price_to_small_first_el =
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 1000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.drop_info)]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateDrops - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "Price should be at least 0.1tez") ) "CreateDrops - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price do not meet minimum price
let test_create_drops_price_to_small_second_el = 
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 1000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.drop_info)]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateDrops - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "Price should be at least 0.1tez") ) "CreateDrops - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if already in drop
let test_create_drops_already_in_drop = 
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                };
            } : FP_I.drop_info)]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateDrops - Already in drop : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_DROPED") ) "CreateDrops - Already in drop : Should not work if token is already in drop" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if already dropped
let test_create_drops_already_dropped =
    let contract_add = get_initial_storage (false, true, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateDrops - Already dropped : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_DROPED") ) "CreateDrops - Already dropped : Should not work if token is already in drop" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Should fail if wrong signature
let test_create_drops_wrong_signature = 
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d65737361676520746573742077726f6e67" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateDrops - Wrong signature : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "CreateDrops - Wrong signature : Should not work if signature is not correct" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if signature already used
let test_create_drops_already_used_signature = 
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let _gas2 = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
    in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateDrops - Already used signature : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "CreateDrops - Already used signature : Should not work if signature is already used" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if wrong drop date
let test_create_drops_wrong_drop_date = 
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let less_than_a_day : int = 6000 in
    let more_than_a_month : int = 2707200 in
    
    let expected_time_result_less = now + less_than_a_day in
    let expected_time_result_more = now + more_than_a_month in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (AddDropSeller (init_str.admin.address))) 0tez in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_less;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
    in

    let () = match result with
            Success _gas -> failwith "CreateDrops - To early drop date : This test should fail"
        |   Fail (Rejected (err, _)) ->  assert_with_error ( Test.michelson_equal err (Test.eval "DROP_DATE_MUST_BE_AT_LEAST_IN_A_DAY") ) "CreateDrops - To early drop date : Should not work if drop_date is in less than a day"
        |   Fail _ -> failwith "Internal test failure"
    in

    let second_result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_more;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
    in

    match second_result with
        Success _gas -> failwith "CreateDrops - Drop date to far : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_DATE_MUST_BE_IN_MAXIMUM_ONE_MONTH") ) "CreateDrops - Drop date to far : Should not work if drop_date is greater than a month" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if not an authorized drop seller
let test_create_drops_not_authorized_drop_seller = 
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let expected_time_result_three = now + three_days in

    let result = Test.transfer_to_contract contract
        (CreateDrops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateDrops - Not authorized to drop : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AUTHORIZED_DROP_SELLER") ) "CreateDrops - Not authorized to drop : Should not work if seller is not whitelisted" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// -- REVOKE DROPS --

// Should sucess if token been already revoked before drop date

// Success before drop date and token removed from dropped big_map
let test_revoke_drops_before_drop_date =
    let contract_add = get_initial_storage (false, true, true, Tezos.now + 22800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (RevokeDrops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base )
            ]
        })) 0tez
    in

    let new_str = Test.get_storage contract_add in
    match result with
        Success _gas -> (
                // Check if drops is revoked from the currently drops big map
                let first_revoke_sale_key : FP_I.fa2_base * address = (
                {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                },
                init_str.admin.address
                ) in
                let () = match Big_map.find_opt first_revoke_sale_key new_str.drops with
                        Some first_revoke_sale_key -> (failwith "RevokeSale - Success : This test should pass (err: First drop should be deleted)" : unit)
                    |   None -> unit
                in
                // Check if the drop is revoked from the dropped big_map
                let first_revoke_sale_dropped_key : FP_I.fa2_base = {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                } in
                let () = match Big_map.find_opt first_revoke_sale_dropped_key new_str.fa2_dropped with
                        Some first_revoke_sale_dropped_key -> (failwith "RevokeSale - Success : This test should pass (err: First drop should be deleted from dropped big_map)" : unit)
                    |   None -> unit
                in
            // Check second sale if well saved
            let second_revoke_sale_key : FP_I.fa2_base * address = (
                {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                },
                init_str.admin.address
                ) in
            let () = match Big_map.find_opt second_revoke_sale_key new_str.drops with
                    Some second_revoke_sale_key -> (failwith "RevokeSale - Success : This test should pass (err: Second drop should be deleted)" : unit)
                |   None -> unit
            in
            // Check if the drop is revoked from the dropped big_map
            let second_revoke_sale_dropped_key : FP_I.fa2_base = {
                address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n
            } in
            let () = match Big_map.find_opt second_revoke_sale_dropped_key new_str.fa2_dropped with
                    Some second_revoke_sale_dropped_key -> (failwith "RevokeSale - Success : This test should pass (err: Second drop should be deleted from dropped big_map)" : unit)
                |   None -> unit
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
        let () = Test.log("err: ", err) in
        "RevokeSale - Success : This test should pass"
    )
    |   Fail _ -> failwith "Internal test failure"    

// Success after drop date + 1 day and token stay in dropped big_map
let test_revoke_drops_after_drope_date =
    let contract_add = get_initial_storage (false, true, true, Tezos.now - 87800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (RevokeDrops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base )
            ]
        })) 0tez
    in

    let new_str = Test.get_storage contract_add in
    match result with
        Success _gas -> (
                // Check if drops is revoked from the currently drops big map
                let first_revoke_sale_key : FP_I.fa2_base * address = (
                {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                },
                init_str.admin.address
                ) in
                let () = match Big_map.find_opt first_revoke_sale_key new_str.drops with
                        Some first_revoke_sale_key -> (failwith "RevokeSale - Success : This test should pass (err: First drop should be deleted)" : unit)
                    |   None -> unit
                in
                // Check if the drop is revoked from the dropped big_map
                let first_revoke_sale_dropped_key : FP_I.fa2_base = {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                } in
                let () = match Big_map.find_opt first_revoke_sale_dropped_key new_str.fa2_dropped with
                        Some first_revoke_sale_dropped_key -> unit
                    |   None -> (failwith "RevokeSale - Success : This test should pass (err: First drop should not be deleted from dropped big_map)" : unit)
                in
            // Check second sale if well saved
            let second_revoke_sale_key : FP_I.fa2_base * address = (
                {
                    address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                },
                init_str.admin.address
                ) in
            let () = match Big_map.find_opt second_revoke_sale_key new_str.drops with
                    Some second_revoke_sale_key -> (failwith "RevokeSale - Success : This test should pass (err: Second drop should be deleted)" : unit)
                |   None -> unit
            in
            // Check if the drop is revoked from the dropped big_map
            let second_revoke_sale_dropped_key : FP_I.fa2_base = {
                address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n
            } in
            let () = match Big_map.find_opt second_revoke_sale_dropped_key new_str.fa2_dropped with
                    Some second_revoke_sale_dropped_key -> unit
                |   None -> (failwith "RevokeSale - Success : This test should pass (err: Second drop should not be deleted from dropped big_map)" : unit)
            in
            "Passed"
        )
    |   Fail (Rejected (err, _)) -> (
        let () = Test.log("err: ", err) in
        "RevokeSale - Success : This test should pass"
    )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount specified
let test_revoke_drops_with_amount =
    let contract_add = get_initial_storage (false, true, true, Tezos.now + 22800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (RevokeDrops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base )
            ]
        })) 1tez
    in

    match result with
        Success _gas -> failwith "RevokeDrops - No amount : This test should fail (err: Amount specified for revoke_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "RevokeDrops - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drops not created
let test_revoke_drops_not_created =
    let contract_add = get_initial_storage (false, false, false, Tezos.now + 22800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (RevokeDrops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base )
            ]
        })) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeDrops - Drops are not created : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_DROPPED") ) "RevokeDrops - Drops are not created : Should not work if drop is not created" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sender not owner
let test_revoke_drops_sender_not_owner =
    let contract_add = get_initial_storage (false, true, true, Tezos.now + 22800) in
    let init_str = Test.get_storage contract_add in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract
        (RevokeDrops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base )
            ]
        })) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeDrops - Drops sender not owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_DROPPED") ) "RevokeDrops - Drops sender not owner : Should not work if sender is not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drop_date in less than 6 hours
let test_revoke_drops_less_than_6_hours_before_drop_date =
    let contract_add = get_initial_storage (false, true, true, Tezos.now + 20800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (RevokeDrops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base )
            ]
        })) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeDrops - Drop date in less than 6 hours : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_CANNOT_BE_REVOKED") ) "RevokeDrops - Drop date in less than 6 hours : Should not work if drop date less than 6 hours" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drop_date < now < 1 day 
let test_revoke_drops_between_drop_date_and_one_day =
    let contract_add = get_initial_storage (false, true, true, Tezos.now + 84800) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (RevokeDrops ({
            fa2_tokens = [({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base );
            ({
                id = 1n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            }: FP_I.fa2_base )
            ]
        })) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeDrops - Drop date was in less than a day : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_CANNOT_BE_REVOKED") ) "RevokeDrops - Drop date was in less than a day : Should not work if drop date was in less than a day" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

