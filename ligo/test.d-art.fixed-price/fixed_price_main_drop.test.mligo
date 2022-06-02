#import "../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../d-art.fixed-price/fixed_price_main.mligo" "FP_M"

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

// -- CREATE DROPS --
let test_create_drops =
   let contract_add = get_initial_storage (false) in
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
    
