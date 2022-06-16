#import "../../d-art.fa2-editions/multi_nft_token_editions.mligo" "E_M"
#import "../../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../../d-art.fixed-price/fixed_price_main.mligo" "FP_M"
#import "../../d-art.fixed-price/common.mligo" "CM"

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
        minters = (Big_map.empty : (address, unit) big_map);
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
    
let get_initial_storage (signature_saved : bool) =
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
    let empty_sellers = (Big_map.empty : (address, unit) big_map ) in
    let empty_drops = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (FP_I.fa2_base, unit) big_map) in

    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = empty_drops;
        fa2_dropped = empty_dropped;
        fee = {
            address = fee_account;
            percent = 35n;
        }
    } in

    let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
    taddr

// Fail if buyer is seller
let test_buy_fixed_price_token_seller_buyer =
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = init_str.admin.address;
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
        } : CM.buy_token)) 0tez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is buyer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SELLER_NOT_AUTHORIZED") ) "Buy_fixed_price_token - Seller is buyer : Should not work if seller is buyer" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if wrong signature
let test_buy_fixed_price_token_wrong_signature =
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
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
        Success _gas -> failwith "Buy_fixed_price_token - Wrong signature : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "Buy_fixed_price_token - Wrong signature : Should not work if signature is not correct" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if signature already used
let test_buy_fixed_price_token_signature_already_used =
    let contract_address = get_initial_storage (true) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in
    
    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in
    
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = no_admin_addr;
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
        })) 100000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Signature already used : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "Buy_fixed_price_token - Signature already used : Should not work if signature is not correct" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if wrong price specified
let test_buy_fixed_price_token_wrong_price = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let init_str = Test.get_storage contract_add in
    
    let admin_addr = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin_addr in
    
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
                    address = (edition_contract : address);
                    id = 0n 
                };
            } : FP_I.sale_info );]
        } : FP_I.sale_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
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
        Success _gas -> failwith "Buy_fixed_price_token - Wrong price specified : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WRONG_PRICE_SPECIFIED") ) "Buy_fixed_price_token - Wrong price specified : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if not buyer
let test_buy_fixed_price_token_not_buyer =
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let edition_contract = get_edition_fa2_contract(contract_address) in
    
    let init_str = Test.get_storage contract_add in
    let admin_addr = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin_addr in
    
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 150000mutez;
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address );
                fa2_token = {
                    address = (edition_contract : address);
                    id = 0n 
                };
            } : FP_I.sale_info );]
        } : FP_I.sale_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract : address);
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
        Success _gas -> failwith "Buy_fixed_price_token - Not specified buyer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SENDER_NOT_AUTHORIZE_TO_BUY") ) "Buy_fixed_price_token - Not specified buyer : Should not work if signature is not correct" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Success - verify fa2 transfer, fee & royalties
let test_buy_fixed_price_token_success =
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    
    let edition_contract = get_edition_fa2_contract(contract_address) in
    let contract_edition_add : (E_M.editions_entrypoints, editions_storage) typed_address = Test.cast_address edition_contract in
    
    let init_str = Test.get_storage contract_add in
    let edition_str = Test.get_storage contract_edition_add in
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract contract_add in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: FP_I.authorization_signature);
            sale_infos = [({
                price = 213210368547757mutez;
                buyer = None;
                fa2_token = {
                    address = (edition_contract : address);
                    id = 0n 
                };
            } : FP_I.sale_info );]
        } : FP_I.sale_configuration)) 0tez
    in

    let buyer = Test.nth_bootstrap_account 1 in
    let token_buyer_bal = Test.get_balance buyer in
    let () = Test.set_source buyer in

    let token_seller_bal = Test.get_balance token_seller in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract : address);
            } : FP_I.fa2_base);
            seller = token_seller;
            buyer = buyer;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: FP_I.authorization_signature);
      
        })) 213210368547757mutez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage contract_edition_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage contract_add in

    match result with
        Success _gas -> (
            // Check that message has been correctly saved 
            let () = match Big_map.find_opt ("54657374206d6573736167652074657374207269676874" : bytes) new_fp_str.admin.signed_message_used with
                    Some _ -> unit
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Signed message not saved)" : unit)
            in
            // Check that sale is deleted from big map
            let sale_key : FP_I.fa2_base * address = (
                {
                    address = (edition_contract : address);
                    id = 0n
                },
                init_str.admin.address
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in    
            
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (7462362899171mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Check that royalties have been sent correctly to minter 50%
            let new_minter_account_bal = Test.get_balance token_minter in
            let () =    if new_minter_account_bal - token_minter_bal = Some (15990777641081mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            // Admin 50% of the royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (15990777641081mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            // Check that seller got the right amount
            let new_token_seller_bal = Test.get_balance token_seller in
            let () =    if new_token_seller_bal - token_seller_bal = Some (173766450366424mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in

            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = buyer
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (err, _)) -> (
            let () = Test.log("errL:", err) in
           failwith "Buy_fixed_price_token - Success : This test should pass"    
        )
    |   Fail err -> (
        let () = Test.log ("err: ", err) in
        failwith "Internal test failure"    
    )

// Fail if seller not owner of token or token not in sale (same case)
let test_buy_fixed_price_token_fail_if_wrong_seller =
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    
    let edition_contract = get_edition_fa2_contract(contract_address) in
    
    let init_str = Test.get_storage contract_add in
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract contract_add in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (edition_contract : address);
            } : FP_I.fa2_base);
            seller = init_str.admin.address;
            buyer = buyer;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: FP_I.authorization_signature);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is not for_sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_IN_SALE") ) "Buy_fixed_price_token - Seller is not for_sale owner : Should not work if seller is not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
