#import "../../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../../d-art.fixed-price/fixed_price_main.mligo" "FP_M"
#import "../../d-art.fixed-price/common.mligo" "CM"
#import "../../d-art.fa2-editions/multi_nft_token_editions.mligo" "E_M"

// This storage is based on the contract fa2_editions
// you can find it at this link https://github.com/D-a-rt/d-art.fa2-editions
// The type below have been taken on the same contract for convenience
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
    hash_used : (bytes, unit) big_map;
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
        minters = Big_map.literal ([(admin), ()]);
    } in

    let asset_strg : nft_token_storage = {
        ledger = Big_map.literal([
                (0n), (token_seller)        
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

    let edition_meta_strg : editions_metadata = Big_map.literal([
        (0n), (edition_meta);
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
    
let get_initial_storage (signature_saved : bool ) =
    let () = Test.reset_state 6n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let buyer = Test.nth_bootstrap_account 1 in
    let fee_account = Test.nth_bootstrap_account 2 in

    let signed_ms = (Big_map.empty : FP_I.signed_message_used) in

    let signed_ms = if signature_saved
        then Big_map.literal([
                ("54657374206d657373616765207465746574657465": bytes), ()        
            ])
        else  (Big_map.empty : FP_I.signed_message_used) 
    in

    let admin_str : FP_I.admin_storage = {
        address = admin;
        pb_key = ("edpkttsmzdmXenJw1s5VoXfrBHdo2f3WX9J3cyYByMj2cQSqzRR9uT" : key);
        signed_message_used = signed_ms;
        contract_will_update = false;
    } in

    let empty_sales = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_sale) big_map ) in
    let empty_sellers = Big_map.literal([(admin), () ]) in
    let drops_str = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (FP_I.fa2_base, unit) big_map) in

    
    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = drops_str;
        fa2_dropped = empty_dropped;
        fee = {
            address = fee_account;
            percent = 35n;
        }
    } in

    let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
    taddr

// Fail if wrong signature
let test_buy_drop_token_wrong_signature = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = no_admin_addr;
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d65737361676520746573742077726f6e67" : bytes);
            }: FP_I.authorization_signature);
        } : FP_I.buy_token)) 0tez
    in

    match result with
        Success _gas -> failwith "Buy_dropped_token - Wrong signature : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "Buy_dropped_token - Wrong signature : Should not work if signature is not correct" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if signature already used
let test_buy_drop_token_signature_already_used =
    let contract_address = get_initial_storage (true) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = no_admin_addr;
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d65737361676520746573742077726f6e67" : bytes);
            }: FP_I.authorization_signature);
        })) 0tez
    in

    match result with
        Success _gas -> failwith "Buy_dropped_token - Signature already used : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "Buy_dropped_token - Signature already used : Should not work if signature is already used" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if wrong price
let test_buy_drop_token_wrong_price =
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in
    
    let admin_addr = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin_addr in
    
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let expected_time_result_three = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract
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
                    id = 0n 
                };
            } : FP_I.drop_info );]
        } : FP_I.drop_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract: address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = no_admin_addr;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: FP_I.authorization_signature);
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
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in
    
    let admin_addr = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin_addr in
    
    let contract = Test.to_contract contract_add in

    let now : timestamp = Tezos.now in
    let three_days : int = 253800 in
    let expected_time_result_three = now + three_days in

    let _gas = Test.transfer_to_contract_exn contract
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
                    id = 0n 
                };
            } : FP_I.drop_info );]
        } : FP_I.drop_configuration)) 0tez
    in


    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract: address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = no_admin_addr;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: FP_I.authorization_signature);
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
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in
    
    let contract = Test.to_contract contract_add in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract: address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = no_admin_addr;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: FP_I.authorization_signature);
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
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    
    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
         (Buy_dropped_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract: address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = init_str.admin.address;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: FP_I.authorization_signature);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is buyer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SELLER_NOT_AUTHORIZED") ) "Buy_fixed_price_token - Seller is buyer : Should not work if seller is buyer" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
