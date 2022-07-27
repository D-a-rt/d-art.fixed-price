#import "../../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../../d-art.fixed-price/fixed_price_main.mligo" "FP_M"

type token_id = nat

type ledger = (token_id, address) big_map

type admin_storage = {
    admin : address;
    paused_minting : bool;
    paused_nb_edition_minting : bool;
    minters : (address, unit) big_map;
}

type operator_storage = ((address * (address * token_id)), unit) big_map

type token_metadata =
[@layout:comb]
  {
    token_id: token_id;
    token_info: ((string, bytes) map);
  }

type nft_token_storage = {
  ledger : ledger;
  operators : operator_storage;
  token_metadata: (token_id, token_metadata) big_map;
}

type split =
[@layout:comb]
{
  address: address;
  pct: nat;
}


type edition_metadata =
[@layout:comb]
{
    minter : address;
    edition_info: (string, bytes) map;
    total_edition_number: nat;
    royalty: nat;
    splits: split list;
}

type editions_metadata = (nat, edition_metadata) big_map

type editions_storage =
{
    next_edition_id : nat;
    max_editions_per_run : nat;
    editions_metadata : editions_metadata;
    assets : nft_token_storage;
    admin : admin_storage;
    metadata: (string, bytes) big_map;
    hash_used: (bytes, unit) big_map;
}

let get_edition_fa2_contract (fixed_price_contract_address : address) = 

    let admin = Test.nth_bootstrap_account 0 in
    let token_seller = Test.nth_bootstrap_account 3 in
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_split = Test.nth_bootstrap_account 5 in

    let admin_strg : admin_storage = {
        admin = admin;
        paused_minting = false;
        paused_nb_edition_minting = false;
        minters = Big_map.literal ([(token_minter), ()]);
    } in

    let asset_strg : nft_token_storage = {
        ledger = Big_map.literal([
                (0n), (token_seller);
                (1n), (token_seller);       
                (250n), (token_seller);
                (500n), (token_seller)        
            ]);
        operators = Big_map.literal([
                ((token_seller, (fixed_price_contract_address, 0n)), ())  ;      
            ]);
        token_metadata = (Big_map.empty : (token_id, token_metadata) big_map);
    } in

    let edition_meta : edition_metadata = ({
            minter = token_minter;
            edition_info = (Map.empty : (string, bytes) map);
            total_edition_number = 2n;
            royalty = 150n;
            splits = [({
                address = token_minter;
                pct = 500n;
            } : split );
            ({
                address = token_split;
                pct = 500n;
            } : split )];
        } : edition_metadata ) in

    let edition_meta_2 : edition_metadata = ({
            minter = token_minter;
            edition_info = (Map.empty : (string, bytes) map);
            total_edition_number = 1n;
            royalty = 150n;
            splits = [({
                address = token_minter;
                pct = 500n;
            } : split );
            ({
                address = token_split;
                pct = 500n;
            } : split )];
        } : edition_metadata ) in

    let edition_meta_3 : edition_metadata = ({
            minter = token_minter;
            edition_info = (Map.empty : (string, bytes) map);
            total_edition_number = 1n;
            royalty = 250n;
            splits = [({
                address = token_minter;
                pct = 500n;
            } : split );
            ({
                address = token_split;
                pct = 500n;
            } : split )];
        } : edition_metadata ) in


    let edition_meta_strg : editions_metadata = Big_map.literal([
        (0n), (edition_meta);
        (1n), (edition_meta_2);
        (2n), (edition_meta_3);
    ]) in

    let edition_strg = {
        next_edition_id = 1n;
        max_editions_per_run = 250n;
        editions_metadata = edition_meta_strg;
        assets = asset_strg;
        admin = admin_strg;
        metadata = (Big_map.empty : (string, bytes) big_map);
        hash_used = (Big_map.empty : (bytes, unit) big_map);
    } in

    // Path of the contract on yout local machine
    let michelson_str = Test.compile_value edition_strg in
    let edition_addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fa2-editions/views.mligo" "editions_main" ([] : string list) michelson_str 0tez in
    edition_addr
    
// Create initial storage
let get_initial_storage (will_update, isDropped, isInDrops, drop_date : bool * bool * bool * timestamp) = 
    let () = Test.reset_state 6n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
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
            let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
            taddr
        )
        else (
            let str = { str with fa2_dropped = dropped } in
            let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
            taddr
        )
    )
    else (
        if isInDrops
        then (
             let str = { str with drops = drops_str } in
            let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
            taddr
        )
        else (
            let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
            taddr

        )
    )

// -- CREATE DROPS --

// Success
let test_create_drops =

    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in

    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 150000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 250n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 100000mutez;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 500n
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
                        |   None -> (failwith "Create_drops - Success : This test should pass (err: Signed message not saved)" : unit)
                in
                // Check first sale if well saved
                let first_drop_key : FP_I.fa2_base * address = (
                    {
                        address = ( edition_contract : address);
                        id = 250n
                    },
                    token_minter
                 ) in
                let () = match Big_map.find_opt first_drop_key new_str.drops with
                        Some fixed_drop_saved -> (
                            let () = assert_with_error (fixed_drop_saved.price = 150000mutez) "Create_drops - Success : This test should pass (err: First sale wrong price saved)" in
                            assert_with_error (fixed_drop_saved.drop_date = expected_time_result_three) "Create_drops - Success : This test should pass (err: First sale wrong date saved)"
                        )
                    |   None -> (failwith "Create_drops - Success : This test should pass (err: First drop not saved)" : unit)
                in
                // Check second sale if well saved
                let second_drop_key : FP_I.fa2_base * address = (
                    {
                        address = ( edition_contract : address);
                        id = 500n
                    },
                    token_minter
                 ) in
                let () = match Big_map.find_opt second_drop_key new_str.drops with
                        Some fixed_drop_saved -> (
                            let () = assert_with_error (fixed_drop_saved.price = 100000mutez) "Create_drops - Success : This test should pass (err: Second drop wrong price saved)" in
                            assert_with_error (fixed_drop_saved.drop_date = expected_time_result_four) "Create_drops - Success : This test should pass (err: Second drop wrong date saved)"
                        )
                    |   None -> (failwith "Create_drops - Success : This test should pass (err: Second drop not saved)" : unit)
                in
                "Passed"
          )
        |   Fail (Rejected (err, _)) ->  "Create_drops - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    
    
// Should fail if amount specified
let test_create_drops_with_amount = 
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
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
        Success _gas -> failwith "Create_drops - No amount : This test should fail (err: Amount specified for create_drops entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Create_drops - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if contract will be deprecated
let test_create_drops_deprecated = 
    let contract_address = get_initial_storage (true, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
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
        Success _gas -> failwith "Create_drops - Will deprecate : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WILL_BE_DEPRECATED") ) "Create_drops - Will deprecate : Should not work if contract will deprecate" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
    
// Should fail if price do not meet minimum price
let test_create_drops_price_to_small_first_el =
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
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
        Success _gas -> failwith "Create_drops - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "Price should be at least 0.1tez") ) "Create_drops - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price do not meet minimum price
let test_create_drops_price_to_small_second_el = 
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in

    let token_minter = Test.nth_bootstrap_account 4 in
    
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 250n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 1000mutez;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 1n
                };
            } : FP_I.drop_info)]
        } : FP_I.drop_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "Create_drops - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "Price should be at least 0.1tez") ) "Create_drops - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if already in drop
let test_create_drops_already_in_drop = 
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in

    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 250n 
                };
            } : FP_I.drop_info ); ({
                drop_date = expected_time_result_four;
                price = 100000mutez;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 250n
                };
            } : FP_I.drop_info)]
        } : FP_I.drop_configuration)) 0tez
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
    let contract_address = get_initial_storage (false, true, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    
    let init_str = Test.get_storage contract_add in

    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
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
        Success _gas -> failwith "Create_drops - Already dropped : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_DROPED") ) "Create_drops - Already dropped : Should not work if token is already in drop" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Should fail if wrong signature
let test_create_drops_wrong_signature = 
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in

    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d65737361676520746573742077726f6e67" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
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
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in

    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let four_days : int = 338400 in
    
    let expected_time_result_three = now + three_days in
    let expected_time_result_four = now + three_days in

    let _gas2 = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 250n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
    in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
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
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in

    let token_minter = Test.nth_bootstrap_account 4 in
    let () = Test.set_source token_minter in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let less_than_a_day : int = 6000 in
    let more_than_a_month : int = 2707200 in
    
    let expected_time_result_less = now + less_than_a_day in
    let expected_time_result_more = now + more_than_a_month in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_less;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 250n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
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
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_more;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
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
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let expected_time_result_three = now + three_days in

    let result = Test.transfer_to_contract contract
        (Create_drops ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            drop_infos = [({
                price = 100000mutez;
                drop_date = expected_time_result_three;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 0n 
                };
            } : FP_I.drop_info )]
        } : FP_I.drop_configuration)) 0tez
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
    let contract_address = get_initial_storage (false, true, true, Tezos.now + 28800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
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
    |   Fail (Rejected (err, _)) -> "RevokeSale - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"    

// Success after drop date + 1 day and token stay in dropped big_map
let test_revoke_drops_after_drope_date =
    let contract_address = get_initial_storage (false, true, true, Tezos.now - 87800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
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
    let contract_address = get_initial_storage (false, true, true, Tezos.now + 22800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
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
        Success _gas -> failwith "Revoke_drops - No amount : This test should fail (err: Amount specified for revoke_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Revoke_drops - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drops not created
let test_revoke_drops_not_created =
    let contract_address = get_initial_storage (false, false, false, Tezos.now + 22800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
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
        Success _gas -> failwith "Revoke_drops - Drops are not created : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_DROPPED") ) "Revoke_drops - Drops are not created : Should not work if drop is not created" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sender not owner
let test_revoke_drops_sender_not_owner =
    let contract_address = get_initial_storage (false, true, true, Tezos.now + 22800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in

    let init_str = Test.get_storage contract_add in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in
    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
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
        Success _gas -> failwith "Revoke_drops - Drops sender not owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_DROPPED") ) "Revoke_drops - Drops sender not owner : Should not work if sender is not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drop_date in less than 6 hours
let test_revoke_drops_less_than_6_hours_before_drop_date =
    let contract_address = get_initial_storage (false, true, true, Tezos.now + 20800) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
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
        Success _gas -> failwith "Revoke_drops - Drop date in less than 6 hours : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_CANNOT_BE_REVOKED") ) "Revoke_drops - Drop date in less than 6 hours : Should not work if drop date less than 6 hours" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if drop_date < now < 1 day 
let test_revoke_drops_between_drop_date_and_one_day =
    let contract_address = get_initial_storage (false, true, true, Tezos.now - 84400) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_drops ({
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
        Success _gas -> failwith "Revoke_drops - Drop date was in less than a day : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "DROP_CANNOT_BE_REVOKED") ) "Revoke_drops - Drop date was in less than a day : Should not work if drop date was in less than a day" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

