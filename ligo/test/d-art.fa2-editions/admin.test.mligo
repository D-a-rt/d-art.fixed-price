#import "storage.test.mligo" "FA2_STR"

// TEST FILE FOR ADMIN ENTRYPOINTS

// -- Pause minting -

// Fail not admin
let test_pause_minting_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Pause_minting (true))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Pause_minting - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Pause_minting - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_pause_minting_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Pause_minting (true))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Pause_minting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Pause_minting - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_pause_minting =
    let contract_add, admin, _, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Pause_minting (true))) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.paused_minting = true) "Admin -> Pause_minting - Success : This test should pass :  Wrong paused_minting" in
    "Passed"

// -- Update minter manager -

// Fail not admin
let test_update_minter_manager_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Update_minter_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Update_minter_manager - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Update_minter_manager - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_update_minter_manager_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Update_minter_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Pause_minting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Update_minter_manager - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_update_minter_manager =
    let contract_add, admin, _, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Update_minter_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address))) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.minters_manager = ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address)) "Admin -> Update_minter_manager - Success : This test should pass :  Wrong minters_manager" in
    "Passed"

// -- FA2 editions version originated from Serie factory contract

#include "../../d-art.fa2-editions/fa2_editions_factory.mligo"

let get_serie_originated_initial_storage (mr: bool) : ( ((editions_entrypoints, editions_storage) typed_address) * address * address * address ) = 
    let () = Test.reset_state 8n ([]: tez list) in
    
    // Admin storage
    let admin = Test.nth_bootstrap_account 0 in
 
    let minter = Test.nth_bootstrap_account 7 in

    let factory_contract_address = FA2_STR.get_factory_contract () in

    let admin_str : admin_storage = {
        admin = admin;
        minting_revoked = mr;
    } in

    // Assets storage
    let owner1 = Test.nth_bootstrap_account 1 in
    let owner2 = Test.nth_bootstrap_account 2 in
    let owner3 = Test.nth_bootstrap_account 3 in
    
    let operator1 = Test.nth_bootstrap_account 4 in
    let operator2 = Test.nth_bootstrap_account 5 in
    let operator3 = Test.nth_bootstrap_account 6 in
    
    let ledger = Big_map.literal([
        (1n, owner1);
        (2n, owner2);
        (3n, owner3);
        (4n, owner1);
    ]) in

    let operators = Big_map.literal([
        ((owner1, (operator1, 1n)), ());
        ((owner2, (operator1, 2n)), ());
        ((owner3, (operator1, 3n)), ());
        ((owner1, (operator1, 4n)), ());
    ]) in

    let edition_info = (Map.empty : (string, bytes) map) in
    let token_metadata = (Big_map.empty : (token_id, token_metadata) big_map) in
    
    let asset_str = {
        ledger = ledger;
        operators = operators;
        token_metadata = token_metadata;
    } in

    // Editions storage
    let edition1 = ({
        edition_info = (Map.empty : (string, bytes) map);
        total_edition_number = 5n;
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : split )];
    } : edition_metadata) in

    let editions_metadata = Big_map.literal([
        (0n, edition1);
    ]) in

    // Contract storage
    let str = {
        next_edition_id = 1n;
        max_editions_per_run = 250n ;
        editions_metadata = editions_metadata;
        assets = asset_str;
        admin = admin_str;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate editions_main str 0tez in
    taddr, admin, owner1, minter

// Revoke minting

// Fail not admin
let test_factory_originated_pause_minting_not_admin =
    let contract_add, _, owner1, _ = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Revoke_minting ({ revoke = true } : revoke_minting_param))) 0tez in

    match result with
        Success _gas -> failwith "Admin (Serie originated fa2 contract) -> Revoke_minting - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Serie originated fa2 contract) -> Revoke_minting - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_factory_originated_pause_minting_not_admin =
    let contract_add, _, owner1, _ = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (Revoke_minting ({ revoke = true } : revoke_minting_param))) 1tez in

    match result with
        Success _gas -> failwith "Admin (Serie originated fa2 contract) -> Revoke_minting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Serie originated fa2 contract) -> Revoke_minting - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_factory_originated_pause_minting =
    let contract_add, admin, _, _ = get_serie_originated_initial_storage(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Admin (Revoke_minting ({ revoke = true } : revoke_minting_param))) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.minting_revoked = true) "Admin (Serie originated fa2 contract) -> Revoke_minting - Success : This test should pass :  Wrong Revoke_minting" in
    "Passed"


