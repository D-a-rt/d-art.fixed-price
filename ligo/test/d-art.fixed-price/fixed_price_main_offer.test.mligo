#include "storage.test.mligo"

// -- CREATE OFFER --

// Fail if will be deprecated
let test_create_offer_will_be_deprecated = 
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (Contract_will_update (true))) 0tez in    

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            commodity = (Tez (1000tez));
        } : offer_conf)) 1000tez
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
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            commodity = (Tez (99999mutez));
        } : offer_conf)) 99999mutez
    in

    match result with
        Success _gas -> failwith "CreateOffer - Offer below 0.1tez : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PRICE_SHOULD_BE_MINIMUM_0.1tez") ) "CreateOffer - Offer below 0.1tez : Should not work if offer below 0.1tez" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    



// Fail if offer already placed
let test_create_offer_already_placed = 
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in 

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            commodity = (Tez (1000tez));
        } : offer_conf)) 1000tez
    in

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            commodity = (Tez (1000tez));
        } : offer_conf)) 1000tez
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
    let add, t_add, _, _, admin = get_fixed_price_contract (false) in

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
    } in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
            commodity = (Tez (1000tez));
        } : offer_conf)) 1000tez
    in

    let new_str = Test.get_storage t_add in

    match Big_map.find_opt (token, admin) new_str.offers with
            None -> (failwith "CreateOffer - Success : This test should pass (err: Offer should be saved in the big_map)" : string)
        |   Some off -> (
                let contract_bal = Test.get_balance add in
                let () = assert_with_error ( contract_bal = 1000tez ) "CreateOffer - Success : Wrong contract bal" in
                let () = assert_with_error ( off = (Tez (1000tez)) ) "CreateOffer - Success : Offer should have the amount sent to the contract" in
                "Passed"
        )
    
// fail if wrong commodity fa2 not supported
let test_create_offer_stablecoin_not_supported = 
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            commodity = (Fa2 ({address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n; amount = 1000n } : fa2_token));
        } : offer_conf)) 1000tez
    in

    match result with
        Success _gas -> failwith "CreateOffer - Stable coin not supported : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_NOT_SUPPORTED") ) "CreateOffer - Stable coin not supported : Should not work if stable coin not supported" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"  
    
// fail if wrong commodity fa2 no amount
let test_create_offer_stablecoin_no_amount = 
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Add_stable_coin ({fa2_base = {address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD": address); id= 0n}; mucoin = 1000000n}))) 0tez in

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            commodity = (Fa2 ({address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n; amount = 1000000n } : fa2_token));
        } : offer_conf)) 1000tez
    in

    match result with
        Success _gas -> failwith "CreateOffer - Stable coin no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = Test.log err in
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "CreateOffer - Stable coin no amount : Should not work if stable coin and amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"      

// fail if wrong commodity min price
let test_create_offer_stablecoin_fa2_min_price =
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in
    
    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Add_stable_coin ({fa2_base = {address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD": address); id= 0n}; mucoin = 1000000n}))) 0tez in

    let result = Test.transfer_to_contract contract
        (Create_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            commodity = (Fa2 ({address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address); id = 0n; amount = 1000n } : fa2_token));
        } : offer_conf)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateOffer - Stable coin min price not met: This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PRICE_SHOULD_BE_MINIMUM_0.1") ) "CreateOffer - Stable coin min price not met : Should not work if min price is not met" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"      

// -- REVOKE OFFER --

// Fail if will be deprecated
let test_revoke_offer_no_offer_placed = 
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract (Admin  (Contract_will_update (true))) 0tez in    

    let result = Test.transfer_to_contract contract
        (Revoke_offer ({
            address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            id = 1n
        } : fa2_base)) 0tez
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
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Revoke_offer ({
            address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            id = 1n
        } : fa2_base)) 10tez
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
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
    } in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
            commodity = (Tez (1000tez));
        } : offer_conf)) 1000tez
    in

    let _gas = Test.transfer_to_contract_exn contract
        (Revoke_offer ({
            address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            id = 1n
        } : fa2_base)) 0tez
    in

    let new_str = Test.get_storage t_add in

    match Big_map.find_opt (token, admin) new_str.offers with
        | None -> "Passed"
        | Some _ -> failwith "RevokeOffer - Success : This test should pass, offer should be removed from big_map"
    
    

// -- ACCEPT OFFER --

// Fail if amount
let test_accept_offer_no_amount = 
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Accept_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            buyer = admin;
        } : accept_offer)) 10tez
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
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
    } in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
            commodity = (Tez (1000tez))
        } : offer_conf)) 1000tez
    in

    let result = Test.transfer_to_contract contract
        (Accept_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            buyer = admin
        } : accept_offer)) 0tez
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
    let _, t_add, _, _, admin = get_fixed_price_contract (false) in
    

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let buyer = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract
        (Accept_offer ({
            fa2_token = {
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            };
            buyer = buyer
        } : accept_offer)) 0tez
    in

    match result with
        Success _gas -> failwith "AcceptOffer - No offer placed : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NO_OFFER_PLACED") ) "AcceptOffer - No offer placed : Should not work if no offer is placed" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_accept_offer_success = 
    let add, t_add, fa2_add, t_fa2_add, _ = get_fixed_price_contract (false) in 
        
    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    // Contract and params
    let contract = Test.to_contract t_add in

    let token = {
                address = (fa2_add : address);
                id = 0n
    } in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
            commodity = (Tez (100tez))
        } : offer_conf)) 100tez
    in

    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in

    let token_seller_bal = Test.get_balance token_seller in

    let _gas = Test.transfer_to_contract_exn contract
        (Accept_offer ({
            fa2_token = token;
            buyer = buyer
        } : accept_offer)) 0mutez
    in


    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    
    // Check that fees been transfer to fee address
    let new_fee_account_bal = Test.get_balance fee_account in
    let () =    if new_fee_account_bal - fee_account_bal = Some (10tez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
    in

    // Check that 50% of the 15% royalties have been sent correctly to minter
    let new_minter_account_bal = Test.get_balance token_minter in
    let () =    if new_minter_account_bal - token_minter_bal = Some (7.5tez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
    in

    // Admin 50% of the 15% royalties here
    let new_token_split_bal = Test.get_balance token_split in
    let () =    if new_token_split_bal - token_split_bal = Some (7.5tez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
    in

    // Check that seller got the right amount
    let new_token_seller_bal = Test.get_balance token_seller in
    let () =    if new_token_seller_bal - token_seller_bal = Some (74tez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong value sent to seller)" : unit)
    in

    let () =    if Test.get_balance add = 0tez
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: contract should have a balance of 0tez)")
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


// Success Gallery contract 
let test_accept_offer_success_commission = 
    let _, t_add, gallery, fa2_add, t_fa2_add, _ = get_fixed_price_contract_gallery (false) in 
        
    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 3 in
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let gallery_bal = Test.get_balance gallery in

    // Contract and params
    let contract = Test.to_contract t_add in

    let token = {
                address = (fa2_add : address);
                id = 0n
    } in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in
    
    let _gas = Test.transfer_to_contract_exn contract
        (Create_offer ({
            fa2_token = token;
            commodity = (Tez (100tez))
        } : offer_conf)) 100tez
    in
    
    let () = Test.set_source token_minter in

    let _gas = Test.transfer_to_contract_exn contract
        (Accept_offer ({
            fa2_token = token;
            buyer = buyer
        } : accept_offer)) 0mutez
    in
    
    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    
    // Check that fees been transfer to fee address
    let new_fee_account_bal = Test.get_balance fee_account in
    let () =    if new_fee_account_bal - fee_account_bal = Some (10tez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
    in

    let new_gallery_account_bal = Test.get_balance gallery in
    let () =    if new_gallery_account_bal - gallery_bal = Some (50tez)
                then unit   
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to commission address)" : unit)
    in
    
    // Admin 50% of the 15% royalties here
    let new_token_split_bal = Test.get_balance token_split in
    let () =    if new_token_split_bal - token_split_bal = Some (7500000mutez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
    in

    // Check that 50% of the 15% royalties have been sent correctly to minter
    // and the rest of the amount
    let new_minter_account_bal = Test.get_balance token_minter in
    let () =    if new_minter_account_bal - token_minter_bal = Some (31500000mutez)
                then unit
                else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
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
