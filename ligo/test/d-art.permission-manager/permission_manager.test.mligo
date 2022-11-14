#import "storage.test.mligo" "PM_STR"

// -- Add_minter --

// No amount

let test_add_minter_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in
    let new_minter = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Add_minter (new_minter) : PM_STR.art_permission_manager) 1tez in

    match result with
            Success _gas -> failwith " Add_minter - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) " Add_minter - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not an admin
let test_add_minter_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract (Add_minter (new_minter) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> failwith " Add_minter - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) " Add_minter - Not admin : Should not work if not admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Already minter
let test_add_minter_already_minter =
    let new_minter = Test.nth_bootstrap_account 1 in
    let contract_add, _ = PM_STR. get_permission_manager_contract((Some (new_minter)), true) in
    let contract = Test.to_contract contract_add  in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Add_minter (new_minter) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> failwith " Add_minter - Already minter : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_MINTER") ) " Add_minter - Already minter : Should not work if aldready a minter" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"

// Success
let test_add_minter_success =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_minter = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Add_minter (new_minter) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                match Big_map.find_opt new_minter new_str.minters with
                        Some _ ->  "Passed"
                    |   None -> failwith " Add_minter - Already minter : This test should pass (no minter saved)"
            )
        |   Fail (Rejected (_err, _)) -> failwith " Add_minter - Already minter : This test should pass"
        |   Fail _ -> failwith "Internal test failure"



// -- Remove_minter --


// No amount
let test_remove_minter_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let old_minter = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Remove_minter (old_minter) : PM_STR.art_permission_manager) 1tez in

    match result with
            Success _gas -> failwith " Remove_minter - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) " Remove_minter - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not an admin
let test_remove_minter_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract (Remove_minter (new_minter) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> failwith " Remove_minter - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) " Remove_minter - Not admin : Should not work if not admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not a minter
let test_remove_minter_not_found =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_minter = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Remove_minter (new_minter) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> "Passed"
        |   Fail (Rejected (_err, _)) -> failwith " Remove_minter - Minter not found : This test should pass"
        |   Fail _ -> failwith "Internal test failure"

// Success
let test_remove_minter_success =
    let new_minter = Test.nth_bootstrap_account 1 in
    let contract_add, _ = PM_STR. get_permission_manager_contract((Some (new_minter)), true) in
    let contract = Test.to_contract contract_add  in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Remove_minter (new_minter) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                match Big_map.find_opt new_minter new_str.minters with
                        Some _ ->  failwith " Remove_minter - Success : This test should pass (minter not removed)"
                    |   None -> "Passed"
            )
        |   Fail (Rejected (_err, _)) -> failwith " Remove_minter - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"


// -- Add_gallery --

// No amount
let test_add_gallery_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_gallery = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Add_gallery (new_gallery) : PM_STR.art_permission_manager) 1tez in

    match result with
            Success _gas -> failwith " Add_gallery - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) " Add_gallery - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not an admin
let test_add_gallery_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_gallery = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_gallery in

    let result = Test.transfer_to_contract contract (Add_gallery (new_gallery) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> failwith " Add_gallery - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) " Add_gallery - Not admin : Should not work if not admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Success
let test_add_gallery_success =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_gallery = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Add_gallery (new_gallery) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                match Big_map.find_opt new_gallery new_str.galleries with
                        Some _ -> "Passed"
                    |   None -> " Add_gallery - Success : This test should pass (no gallery saved)"
            )
        |   Fail (Rejected (_err, _)) -> failwith " Add_gallery - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"



// Already gallery
let test_add_gallery_already_gallery =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None : address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_gallery = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Add_gallery (new_gallery) : PM_STR.art_permission_manager) 0tez in
    let result = Test.transfer_to_contract contract (Add_gallery (new_gallery) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> failwith " Add_gallery - Already gallery : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_GALLERY") ) " Add_gallery - Already gallery : Should not work if aldready a gallery" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"


// -- Remove_gallery --

// No amount
let test_remove_gallery_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let old_gallery = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Remove_gallery (old_gallery) : PM_STR.art_permission_manager) 1tez in

    match result with
            Success _gas -> failwith " Remove_gallery - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) " Remove_gallery - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not an admin
let test_remove_gallery_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_gallery = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_gallery in

    let result = Test.transfer_to_contract contract (Remove_gallery (new_gallery) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> failwith " Remove_gallery - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) " Remove_gallery - Not admin : Should not work if not admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not a gallery
let test_remove_gallery_not_found =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_gallery = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Remove_gallery (new_gallery) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> "Passed"
        |   Fail (Rejected (_err, _)) -> failwith " Remove_gallery - Gallery not found : This test should pass"
        |   Fail _ -> failwith "Internal test failure"

// Success
let test_remove_gallery_success =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None : address option), true) in
    let contract = Test.to_contract contract_add  in
    
    let new_gallery = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Add_gallery (new_gallery) : PM_STR.art_permission_manager) 0tez in
    let result = Test.transfer_to_contract contract (Remove_gallery (new_gallery) : PM_STR.art_permission_manager) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                match Big_map.find_opt new_gallery new_str.galleries with
                        Some _ -> " Remove_gallery - Success : This test should pass (error: minter not removed)"
                    |   None -> "Passed"
            )
        |   Fail (Rejected (_err, _)) -> failwith " Remove_gallery - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"

// -- Add_admin --

// fail no amount
let test_edition_add_admin_no_amount = 
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    
    let contract = Test.to_contract contract_add in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in
    
    let result = Test.transfer_to_contract contract (Add_admin (admin) : PM_STR.art_permission_manager) 1tez in

    match result with
        Success _gas -> failwith " Add_admin - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) " Add_admin - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"
    
// fail not an admin
let test_add_admin_not_admin = 
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add in
    
    let minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source minter in
    
    let result = Test.transfer_to_contract contract (Add_admin (minter) : PM_STR.art_permission_manager ) 0tez in

    match result with
        Success _gas -> failwith " Add_admin - not an admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) " Add_admin - not an admin : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Fail already admin
let test_add_admin_already_admin = 
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in
    let result = Test.transfer_to_contract contract (Add_admin (admin) : PM_STR.art_permission_manager) 0tez in

    match result with
        Success _gas -> failwith " Add_admin - already admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_ADMIN") ) " Add_admin - already admin : Should not work if already an admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"
    
// Success
let test_add_admin_success = 
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add in

    let admin = Test.nth_bootstrap_account 0 in
    let minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source admin in
    
    let result = Test.transfer_to_contract contract (Add_admin (minter) : PM_STR.art_permission_manager ) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Map.find_opt minter strg.admins with
                    Some _ -> "Passed"
                |   None -> failwith " Add_admin - Success : This test should pass (new admin should be added to map)"
               
        )
    |   Fail (Rejected (_err, _)) -> failwith " Add_admin - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"
    
// -- Remove_admin --

// fail no amount
let test_remove_admin_no_amount = 
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add in

    let admin = Test.nth_bootstrap_account 0 in
    let minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source admin in
    
    let result = Test.transfer_to_contract contract (Remove_admin (minter) : PM_STR.art_permission_manager ) 1tez in

    match result with
        Success _gas -> failwith " Remove_admin - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) " Remove_admin - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// fail not admin
let test_remove_admin_not_admin = 
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add in
    
    let admin = Test.nth_bootstrap_account 0 in
    let minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract (Remove_admin (admin) : PM_STR.art_permission_manager ) 0tez in

    match result with
        Success _gas -> failwith " Remove_admin - not an admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) " Remove_admin - not an admin : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// fail one admin left
let test_remove_admin_one_left = 
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in
    let result = Test.transfer_to_contract contract (Remove_admin (admin) : PM_STR.art_permission_manager ) 0tez in

    match result with
        Success _gas -> failwith " Remove_admin - one admin left : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINIMUM_1_ADMIN") ) " Remove_admin - one admin left : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_remove_admin_success = 
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add in

    let admin = Test.nth_bootstrap_account 0 in
    let minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Add_admin (minter) : PM_STR.art_permission_manager) 0tez in
    let result = Test.transfer_to_contract contract (Remove_admin (minter) : PM_STR.art_permission_manager) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Map.find_opt minter strg.admins with
                    Some _ -> failwith " Remove_admin - Success : This test should pass (new admin should be removed from map)"
                |   None ->  "Passed"
               
        )
    |   Fail (Rejected (_err, _)) -> failwith " Remove_admin - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"
