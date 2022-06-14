#import "../../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../../d-art.fixed-price/fixed_price_main.mligo" "FP_M"

// Create initial storage
let get_initial_storage (will_update : bool) = 
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

    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = empty_drops;
        fa2_dropped = empty_dropped;
        fee = {
            address = admin;
            percent = 3n;
        }
    } in

    let taddr, _, _ = Test.originate FP_M.fixed_price_tez_main str 0tez in
    taddr

// -- CREATE SALES --

// Success
let test_create_sales =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    let new_str = Test.get_storage contract_add in
    match result with
          Success _gas -> (
              // Check message is well saved
                let () = match Big_map.find_opt ("54657374206d657373616765207465746574657465" : bytes) new_str.admin.signed_message_used with
                            Some _ -> unit
                        |   None -> (failwith "CreateSale - Success : This test should pass (err: Signed message not saved)" : unit)
                in
                // Check first sale if well saved
                let first_sale_key : FP_I.fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 0n
                    },
                    init_str.admin.address
                 ) in
                let () = match Big_map.find_opt first_sale_key new_str.for_sale with
                        Some fixed_price_saved -> (
                            let () = assert_with_error (fixed_price_saved.price = 150000mutez) "CreateSale - Success : This test should pass (err: First sale wrong price saved)" in
                            match fixed_price_saved.buyer with 
                                    Some _ -> (failwith "CreateSale - Success : This test should pass (err: First sale no buyer should be saved)" : unit)
                                |   None -> unit
                        )
                    |   None -> (failwith "CreateSale - Success : This test should pass (err: First sale not saved)" : unit)
                in
                // Check second sale if well saved
                let second_sale_key : FP_I.fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 1n
                    },
                    init_str.admin.address
                 ) in
                let () = match Big_map.find_opt second_sale_key new_str.for_sale with
                        Some fixed_price_saved -> (
                            let () = assert_with_error (fixed_price_saved.price = 100000mutez) "CreateSale - Success : This test should pass (err: Second sale wrong price saved)" in
                            match fixed_price_saved.buyer with 
                                    Some buyer -> assert_with_error (buyer = ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address)) "CreateSale - Success : This test should pass (err: Second sale wrong buyer saved)"
                                |   None -> (failwith "CreateSale - Success : This test should pass (err: Second sale buyer should be saved)" : unit)
                        )
                    |   None -> (failwith "CreateSale - Success : This test should pass (err: Second sale not saved)" : unit)
                in
                "Passed"
          )
        |   Fail (Rejected (err, _)) -> "CreateSale - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    
    

// Should fail if amount specified
let test_create_sales_with_amount =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 1tez
    in

    match result with
        Success _gas -> failwith "CreateSale - No amount : This test should fail (err: Amount specified for create_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "CreateSale - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if contract will be deprecated
let test_create_sales_deprecated = 
    let contract_add = get_initial_storage (true) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Will deprecate : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WILL_BE_DEPRECATED") ) "CreateSale - Will deprecate : Should not work if contract will deprecate" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price not met minimum price
let test_create_sales_price_to_small_first_el =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 10mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "Price should be at least 0.1tez") ) "CreateSale - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price not met minimum price
let test_create_sales_price_to_small_third_el =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 100000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 10mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 2n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "Price should be at least 0.1tez") ) "CreateSale - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if already on sale
let test_create_sales_already_on_sale_one_call =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    // One call verifying that bulk operation fail
    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 100000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                }
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Already on sale one call : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_ON_SALE") ) "CreateSale - Already on sale one call : Should not work if already on sale" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
    

// Should fail if already on sale
let test_create_sales_already_on_sale_second_call =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 100000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                }
            } : FP_I.sale_info )]
        } : FP_I.sale_configuration)) 0tez
    in

    // Second call to verify that if fails
    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigtruMgRd6FbVWg5pbfFabZC7DS7gr88xT1x4DPxkuGxvUG4S7ttXoAsqy3QfyK62Woj7CmjzCgFW2igdhAhgUuBHfjrLeUv" : signature);
                message = ("54657374206d6573736167652074657374" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 100000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                }
            } : FP_I.sale_info )]
        } : FP_I.sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Already on sale second call : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_ON_SALE") ) "CreateSale - Already on sale second call : Should not work if already on sale" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
    
// Should fail if specified buyer is seller
let test_create_sales_buyer_is_seller =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some (init_str.admin.address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Buyer is seller : This test should fail (err: Buyer cannot be seller)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "BUYER_CANNOT_BE_SELLER") ) "CreateSale - Buyer is seller : Should not work if buyer is seller" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if wrong signature
let test_create_sales_wrong_signature = 
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d65737361676520746573742077726f6e67" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Wrong signature : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "CreateSale - Wrong signature : Should not work if signature is not correct" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if signature already used
let test_create_sales_already_used_signature = 
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 2n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 3n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Already used signature : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "CreateSale - Already used signature : Should not work if signature is already used" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// -- UPDATE SALES --

// Success
let test_update_sales = 
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    // Changing sale infos (switching buyer option and prices) - Changing two times the same sale and verify last result is taken
    let result = Test.transfer_to_contract contract
        (Update_sales ([({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 250000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 130000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info);
            ({
                buyer = None;
                price = 170000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)])
        ) 0tez
    in

    let new_str = Test.get_storage contract_add in
    match result with
          Success _gas -> (
                // Check first sale if well saved
                let first_update_sale_key : FP_I.fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 0n
                    },
                    init_str.admin.address
                 ) in
                let () = match Big_map.find_opt first_update_sale_key new_str.for_sale with
                        Some fixed_price_saved -> (
                            let () = assert_with_error (fixed_price_saved.price = 250000mutez) "UpdateSale - Success : This test should pass (err: First sale wrong updated price saved)" in
                            match fixed_price_saved.buyer with 
                                    Some buyer -> assert_with_error (buyer = ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address)) "UpdateSale - Success : This test should pass (err: Second sale wrong buyer saved while updating)"
                                |   None -> (failwith "UpdateSale - Success : This test should pass (err: First sale new buyer should be saved)" : unit)
                        )
                    |   None -> (failwith "UpdateSale - Success : This test should pass (err: First sale should not be deleted)" : unit)
                in
                // Check second sale if well saved
                let second_sale_update_key : FP_I.fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 1n
                    },
                    init_str.admin.address
                 ) in
                let () = match Big_map.find_opt second_sale_update_key new_str.for_sale with
                        Some fixed_price_saved -> (
                            let () = assert_with_error (fixed_price_saved.price = 170000mutez) "UpdateSale - Success : This test should pass (err: Second sale wrong updated price saved)" in
                            match fixed_price_saved.buyer with 
                                    Some _ ->  (failwith "UpdateSale - Success : This test should pass (err: Second sale new buyer should be none)" : unit)
                                |   None -> unit
                        )
                    |   None -> (failwith "UpdateSale - Success : This test should pass (err: Second sale should not be deleted)" : unit)
                in
                "Passed"
          )
        |   Fail (Rejected (err, _)) -> "UpdateSale - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount specified
let test_update_sales_amount_specified =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Update_sales ([({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 250000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 130000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)])
        ) 1tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - No amount : This test should fail (err: Amount specified for update_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "UpdateSale - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price does not meet minimum price
let test_update_sales_to_small_first_el =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 130000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "Price should be at least 0.1tez") ) "UpdateSale - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Should fail if price does not meet minimum price
let test_update_sales_to_small_second_el =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 130000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 100mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "Price should be at least 0.1tez") ) "UpdateSale - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if updated buyer is seller
let test_update_sales_buyer_is_sender = 
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = Some (init_str.admin.address);
                price = 130000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 100mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Buyer is sender : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "BUYER_CANNOT_BE_SELLER") ) "UpdateSale - Buyer is sender : Should not work if buyer is sender" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sender is not owner of the sale
let test_update_sales_not_owner =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    // Attacker trying to change sale params to there own address an change the price
    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = Some (no_admin_addr : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some (no_admin_addr : address);
                price = 1000000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Not sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_SELLER_OR_NOT_FOR_SALE") ) "UpdateSale - Not sale owner : Should not work if sender is not seller" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"   


// Should fail if sale is not created
let test_update_sales_not_created =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = None;
                price = 130000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = None;
                price = 100mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Sale is not created : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_SELLER_OR_NOT_FOR_SALE") ) "UpdateSale - Sale is not created : Should not work if sale is not created" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// -- REVOKE SALE --

// Success
let test_revoke_sales = 
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    // Changing sale infos (switching buyer option and prices) - Changing two times the same sale and verify last result is taken
    let result = Test.transfer_to_contract contract
        (Revoke_sales ({
            fa2_tokens = [
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n 
            } : FP_I.fa2_base ); 
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            }: FP_I.fa2_base)
        ]} : FP_I.revoke_param)) 0tez
    in

    let new_str = Test.get_storage contract_add in
    match result with
          Success _gas -> (
                // Check first sale if well saved
                let first_deleted_sale_key : FP_I.fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 0n
                    },
                    init_str.admin.address
                 ) in
                let () = match Big_map.find_opt first_deleted_sale_key new_str.for_sale with
                        Some fixed_price_saved -> (failwith "RevokeSale - Success : This test should pass (err: First sale should be deleted)" : unit)
                    |   None -> unit
                in
                // Check second sale if well saved
                let second_deleted_sale_key : FP_I.fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 1n
                    },
                    init_str.admin.address
                 ) in
                let () = match Big_map.find_opt second_deleted_sale_key new_str.for_sale with
                        Some fixed_price_saved -> (failwith "RevokeSale - Success : This test should pass (err: Second sale should be deleted)" : unit)
                    |   None -> unit
                in
                "Passed"
          )
        |   Fail (Rejected (err, _)) -> "RevokeSale - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount specified
let test_revoke_sales_with_amount = 
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_sales ({
            fa2_tokens = [
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n 
            } : FP_I.fa2_base ); 
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            }: FP_I.fa2_base)
        ]} : FP_I.revoke_param)) 1tez
    in

    match result with
        Success _gas -> failwith "RevokeSale - No amount : This test should fail (err: Amount specified for revoke_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "RevokeSale - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sale is not created
let test_revoke_sales_not_created =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

   let result = Test.transfer_to_contract contract
        (Revoke_sales ({
            fa2_tokens = [
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n 
            } : FP_I.fa2_base ); 
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            }: FP_I.fa2_base)
        ]} : FP_I.revoke_param)) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeSale - Sale is not created : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_SELLER_OR_NOT_FOR_SALE") ) "RevokeSale - Sale is not created : Should not work if sale is not created" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sender not owner
let test_revoke_sales_not_owner =
    let contract_add = get_initial_storage (false) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : FP_I.sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                price = 100000mutez;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : FP_I.sale_info)]
        } : FP_I.sale_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

   let result = Test.transfer_to_contract contract
        (Revoke_sales ({
            fa2_tokens = [
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n 
            } : FP_I.fa2_base ); 
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            }: FP_I.fa2_base)
        ]} : FP_I.revoke_param)) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeSale - Not sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_SELLER_OR_NOT_FOR_SALE") ) "RevokeSale - Not sale owner : Should not work if not sale owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
