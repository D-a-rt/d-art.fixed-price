#import "../../d-art.fa2-editions/multi_nft_token_editions.mligo" "E_M"
#import "../../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../../d-art.fixed-price/fixed_price_main.mligo" "FP_M"
#import "../../d-art.serie-factory/serie_factory.mligo" "S_F"

// Create initial storage
let get_initial_storage (will_update : bool) = 
    let () = Test.reset_state 8n ([]: tez list) in
    let admin = Test.nth_bootstrap_account 0 in
    let fee_account = Test.nth_bootstrap_account 2 in
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
    let empty_offers = (Big_map.empty : (FP_I.fa2_base * address, tez) big_map) in

    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = empty_drops;
        fa2_sold = empty_dropped;
        fa2_dropped = empty_dropped;
        offers = empty_offers;
        fee_primary = {
            address = fee_account;
            percent = 100n;
        };
        fee_secondary = {
            address = fee_account;
            percent = 30n;
        };
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
    taddr

let get_factory_contract () =
    
    let admin_str = {
        admin = Test.nth_bootstrap_account 0;
        pending_admin = (None: address option);
    } in

    let str = {
        admin = admin_str;
        origination_paused = false;
        minters = (Big_map.empty : (address, unit) big_map);
        series = (Big_map.empty : (nat, S_F.serie) big_map);
        metadata = (Big_map.empty : (string, bytes) big_map);
        next_serie_id = 1n;
    } in

    let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.serie-factory/serie_factory.mligo" "art_serie_factory_main" ([] : string list) (Test.compile_value str) 0tez in
    taddr

let get_edition_fa2_contract (factory_contract, fixed_price_contract_address : address * address) = 
    
    let admin = Test.nth_bootstrap_account 0 in
    let buyer = Test.nth_bootstrap_account 1 in
    let token_seller = Test.nth_bootstrap_account 3 in
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_split = Test.nth_bootstrap_account 5 in

    let admin_strg : E_M.admin_storage = {
        admin = admin;
        paused_minting = false;
        minters_manager = factory_contract;
    } in

    let asset_strg : E_M.nft_token_storage = {
        ledger = Big_map.literal([
                (0n), (token_seller)        
            ]);
        operators = Big_map.literal([
                ((token_seller, (fixed_price_contract_address, 0n)), ())  ;
                ((buyer, (fixed_price_contract_address, 0n)), ())  ;      
            ]);
        token_metadata = (Big_map.empty : (E_M.token_id, E_M.token_metadata) big_map);
    } in

    let edition_meta : E_M.edition_metadata = ({
            minter = admin;
            edition_info = (Map.empty : (string, bytes) map);
            total_edition_number = 2n;
            royalty = 150n;
            splits = [({
                address = token_minter;
                pct = 500n;
            } : E_M.split );
            ({
                address = token_split;
                pct = 500n;
            } : E_M.split )];
        } : E_M.edition_metadata ) in

    let edition_meta_strg : E_M.editions_metadata = Big_map.literal([
        (0n), (edition_meta);
    ]) in

    let edition_strg = {
        next_edition_id = 1n;
        max_editions_per_run = 250n;
        editions_metadata = edition_meta_strg;
        assets = asset_strg;
        admin = admin_strg;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    // Path of the contract on yout local machine
    let michelson_str = Test.compile_value edition_strg in
    let edition_addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fa2-editions/views.mligo" "editions_main" ([] : string list) michelson_str 0tez in
    edition_addr
    

// -- CREATE OFFER --

// Fail if will be deprecated
let test_create_offer_will_be_deprecated = 
    let contract_address = get_initial_storage (true) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
        } : FP_I.offer_conf)) 1000tez
    in

    match result with
        Success _gas -> failwith "CreateOffer - Will deprecate : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WILL_BE_DEPRECATED") ) "CreateOffer - Will deprecate : Should not work if contract will deprecate" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Fail if offer below 0.1 tez
let test_create_offer_already_placed = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
        } : FP_I.offer_conf)) 99999mutez
    in

    match result with
        Success _gas -> failwith "CreateOffer - Offer below 0.1tez : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_MINIMUM_0.1_TEZ") ) "CreateOffer - Offer below 0.1tez : Should not work if offer below 0.1tez" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    



// Fail if offer already placed
let test_create_offer_already_placed = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
        } : FP_I.offer_conf)) 1000tez
    in

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
        } : FP_I.offer_conf)) 1000tez
    in

    match result with
        Success _gas -> failwith "CreateOffer - Offer already placed : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "OFFER_ALREADY_PLACED") ) "CreateOffer - Offer already placed : Should not work if already placed order" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Success
let test_create_offer_success = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
    } in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
        } : FP_I.offer_conf)) 1000tez
    in

    let new_str = Test.get_storage contract_add in

    let () = match Big_map.find_opt (token, init_str.admin.address) new_str.offers with
        | None -> (failwith "CreateOffer - Success : This test should pass (err: Offer should be saved in the big_map)" : unit)
        | Some off -> assert_with_error ( off = 1000tez ) "CreateOffer - Success : Offer should have the amount sent to the contract" 
    in
    "Passed"


// -- REVOKE OFFER --

// Fail if will be deprecated
let test_revoke_offer_no_offer_placed = 
    let contract_address = get_initial_storage (true) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
        } : FP_I.offer_conf)) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeOffer - No offer placed : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NO_OFFER_PLACED") ) "RevokeOffer - No offer placed : Should not work if no offer is placed" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Fail if amount
let test_revoke_offer_no_amount = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Revoke_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
        } : FP_I.offer_conf)) 10tez
    in

    match result with
        Success _gas -> failwith "RevokeOffer - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "RevokeOffer - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Success
let test_create_offer_success = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
    } in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
        } : FP_I.offer_conf)) 1000tez
    in

    let _gas = Test.transfer_to_contract_exn contract
        (Revoke_offer ({
            fa2_token = token;
        } : FP_I.offer_conf)) 0tez
    in

    let new_str = Test.get_storage contract_add in

    match Big_map.find_opt (token, init_str.admin.address) new_str.offers with
        | None -> "Passed"
        | Some _ -> failwith "RevokeOffer - Success : This test should pass, offer should be removed from big_map"
    
    

// -- ACCEPT OFFER --

// Fail if amount
let test_accept_offer_no_amount = 
    let contract_address = get_initial_storage (true) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let result = Test.transfer_to_contract contract
        (Accept_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            buyer = init_str.admin.address;
        } : FP_I.accept_offer)) 10tez
    in

    match result with
        Success _gas -> failwith "RevokeOffer - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "RevokeOffer - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Fail if buyer is seller
let test_accept_offer_buyer_is_seller = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in

    let token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
    } in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
        } : FP_I.offer_conf)) 1000tez
    in

    let result = Test.transfer_to_contract contract
        (Accept_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            buyer = init_str.admin.address
        } : FP_I.accept_offer)) 0tez
    in

    match result with
        Success _gas -> failwith "AcceptOffer - Buyer is seller : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "BUYER_CANNOT_BE_SELLER") ) "AcceptOffer - Buyer is seller : Should not work if buyer is the seller" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Fail if no offer placed
let test_accept_no_offer_placed = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let init_str = Test.get_storage contract_add in

    let () = Test.set_source init_str.admin.address in
    let contract = Test.to_contract contract_add in
    let buyer = Test.nth_bootstrap_account 1 in

    let token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
    } in

    let result = Test.transfer_to_contract contract
        (Accept_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            buyer = buyer
        } : FP_I.accept_offer)) 0tez
    in

    match result with
        Success _gas -> failwith "AcceptOffer - No offer placed : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NO_OFFER_PLACED") ) "AcceptOffer - No offer placed : Should not work if no offer is placed" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_create_offer_success = 
    let contract_address = get_initial_storage (false) in
    let contract_add : (FP_M.fixed_price_entrypoints, FP_I.storage) typed_address = Test.cast_address contract_address in
    let factory_contract_address = get_factory_contract () in
    
    let edition_contract = get_edition_fa2_contract(factory_contract_address, contract_address) in
    let contract_edition_add : (E_M.editions_entrypoints, E_M.editions_storage) typed_address = Test.cast_address edition_contract in
    
    let init_str = Test.get_storage contract_add in
    let edition_str = Test.get_storage contract_edition_add in
    
    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    // Contract and params
    let contract = Test.to_contract contract_add in

    let token = {
                address = (edition_contract : address);
                id = 0n
    } in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
        } : FP_I.offer_conf)) 100tez
    in

    let token_buyer_bal = Test.get_balance buyer in

    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in

    let token_seller_bal = Test.get_balance token_seller in

    let _gas = Test.transfer_to_contract_exn contract
        (Accept_offer ({
            fa2_token = token;
            buyer = buyer
        } : FP_I.accept_offer)) 0mutez
    in


    // To check the result of the edition storage account
    let edition_str = Test.get_storage contract_edition_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage contract_add in

    // Check that fees been transfer to fee address
    let new_fee_account_bal = Test.get_balance fee_account in
    let () =    if new_fee_account_bal - fee_account_bal = Some (10tez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
    in

    // Check that 50% of the 15% royalties have been sent correctly to minter
    let new_minter_account_bal = Test.get_balance token_minter in
    let () =    if new_minter_account_bal - token_minter_bal = Some (7500000mutez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
    in

    // Admin 50% of the 15% royalties here
    let new_token_split_bal = Test.get_balance token_split in
    let () =    if new_token_split_bal - token_split_bal = Some (7500000mutez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
    in

    // Check that seller got the right amount
    let new_token_seller_bal = Test.get_balance token_seller in
    let () =    if new_token_seller_bal - token_seller_bal = Some (74tez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong value sent to seller)" : unit)
    in

    // Check that buyer owns the token
    let () = match Big_map.find_opt 0n edition_str.assets.ledger with
            Some add -> (
                if add = buyer
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong address to the token)" : unit) 
            )
        |   None -> (failwith "AcceptOffer - Success : This test should pass (err: Token should have a value)" : unit)
    in
    "Passed"
