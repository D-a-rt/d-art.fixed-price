#import "../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../d-art.fixed-price/fixed_price_main.mligo" "FP_M"

module List_helper = struct
    let nth_exn (type a) (i : int) (a: a list) : a =
        let rec aux (remaining: a list) (cur: int) : a =
            match remaining with
                [] -> failwith "Not found in list"
            |   hd :: tl ->
                    if cur = i then
                        hd
                    else aux tl (cur + 1)
        in
        aux a 0
end 

// Create initial storage
let get_initial_storage () = 
    let admin = Test.nth_bootstrap_account 0 in
    let signed_ms = (Big_map.empty : FP_I.signed_message_used) in
    
    let admin_str : FP_I.admin_storage = {
        address = admin;
        pb_key = ("edpkttsmzdmXenJw1s5VoXfrBHdo2f3WX9J3cyYByMj2cQSqzRR9uT" : key);
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
        authorized_drops_seller = empty_sellers;
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
    let contract_add = get_initial_storage () in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (CreateSales ({
            seller = init_str.admin.address;
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
    let contract_add = get_initial_storage () in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (CreateSales ({
            seller = init_str.admin.address;
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
