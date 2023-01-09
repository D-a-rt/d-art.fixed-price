#import "storage.test.mligo" "PM_STR"

// -- Add_minter --

// No amount

let test_add_minter_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in
    let new_minter = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Admin (Add_minter (new_minter))) 1tez in

    match result with
            Success _gas -> failwith "Admin -> Add_minter - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Add_minter - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not an admin
let test_add_minter_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract (Admin (Add_minter (new_minter))) 0tez in

    match result with
            Success _gas -> failwith "Admin -> Add_minter - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Add_minter - Not admin : Should not work if not admin" in
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

    let result = Test.transfer_to_contract contract (Admin (Add_minter (new_minter))) 0tez in

    match result with
            Success _gas -> failwith "Admin -> Add_minter - Already minter : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_MINTER") ) "Admin -> Add_minter - Already minter : Should not work if aldready a minter" in
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

    let result = Test.transfer_to_contract contract (Admin (Add_minter (new_minter))) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                match Big_map.find_opt new_minter new_str.minters with
                        Some _ ->  "Passed"
                    |   None -> failwith "Admin -> Add_minter - Already minter : This test should pass (no minter saved)"
            )
        |   Fail (Rejected (_err, _)) -> failwith "Admin -> Add_minter - Already minter : This test should pass"
        |   Fail _ -> failwith "Internal test failure"



// -- Remove_minter --


// No amount
let test_remove_minter_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let old_minter = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Admin (Remove_minter (old_minter))) 1tez in

    match result with
            Success _gas -> failwith "Admin -> Remove_minter - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Remove_minter - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not an admin
let test_remove_minter_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_minter = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract (Admin (Remove_minter (new_minter))) 0tez in

    match result with
            Success _gas -> failwith "Admin -> Remove_minter - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Remove_minter - Not admin : Should not work if not admin" in
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

    let result = Test.transfer_to_contract contract (Admin (Remove_minter (new_minter))) 0tez in

    match result with
            Success _gas -> "Passed" 
        |   Fail (Rejected (_err, _)) -> failwith "Admin -> Remove_minter - Minter not found : This test should pass"
        |   Fail _ -> failwith "Internal test failure"

// Success
let test_remove_minter_success =
    let new_minter = Test.nth_bootstrap_account 1 in
    let contract_add, _ = PM_STR. get_permission_manager_contract((Some (new_minter)), true) in
    let contract = Test.to_contract contract_add  in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Admin (Remove_minter (new_minter))) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                match Big_map.find_opt new_minter new_str.minters with
                        Some _ ->  failwith "Admin -> Remove_minter - Success : This test should pass (minter not removed)"
                    |   None -> "Passed"
            )
        |   Fail (Rejected (_err, _)) -> failwith "Admin -> Remove_minter - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"



// -- Add_space_manager --

// No amount
let test_add_space_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_space_manager = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Admin (Add_space_manager (new_space_manager))) 1tez in

    match result with
            Success _gas -> failwith "Admin -> Add_space_manager - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Add_space_manager - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not an admin
let test_add_space_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_space_manager = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_space_manager in

    let result = Test.transfer_to_contract contract (Admin (Add_space_manager (new_space_manager))) 0tez in

    match result with
            Success _gas -> failwith "Admin -> Add_space_manager - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Add_space_manager - Not admin : Should not work if not admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Success
let test_add_space_success =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_space_manager = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Admin (Add_space_manager (new_space_manager))) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                match Big_map.find_opt new_space_manager new_str.space_managers with
                        Some _ -> "Passed"
                    |   None -> "Admin -> Add_space_manager - Success : This test should pass (no space saved)"
            )
        |   Fail (Rejected (_err, _)) -> failwith "Admin -> Add_space_manager - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"



// Already minter
let test_add_space_already_minter =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None : address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_space_manager = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Add_space_manager (new_space_manager))) 0tez in
    let result = Test.transfer_to_contract contract (Admin (Add_space_manager (new_space_manager))) 0tez in

    match result with
            Success _gas -> failwith "Admin -> Add_space_manager - Already space : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_SPACE_MANAGER") ) "Admin -> Add_space_manager - Already space : Should not work if aldready a space" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"


// -- Remove_space_manager --

// No amount
let test_remove_space_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let old_space_manager = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Admin (Remove_space_manager (old_space_manager))) 1tez in

    match result with
            Success _gas -> failwith "Admin -> Remove_space_manager - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Remove_space_manager - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not an admin
let test_remove_space_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_space_manager = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_space_manager in

    let result = Test.transfer_to_contract contract (Admin (Remove_space_manager (new_space_manager))) 0tez in

    match result with
            Success _gas -> failwith "Admin -> Remove_space_manager - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Remove_space_manager - Not admin : Should not work if not admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Not a space
let test_remove_space_not_found =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_space_manager = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Admin (Remove_space_manager (new_space_manager))) 0tez in

    match result with
            Success _gas -> "Passed" 
        |   Fail (Rejected (_err, _)) -> failwith "Admin -> Remove_space_manager - Minter not found : This test should pass"
        |   Fail _ -> failwith "Internal test failure"

// Success
let test_remove_space_success =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None : address option), true) in
    let contract = Test.to_contract contract_add  in


    let new_space_manager = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Add_space_manager (new_space_manager))) 0tez in
    let result = Test.transfer_to_contract contract (Admin (Remove_space_manager (new_space_manager))) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                match Big_map.find_opt new_space_manager new_str.space_managers with
                        Some _ -> "Admin -> Remove_space_manager - Success : This test should pass (error: minter not removed)"
                    |   None -> "Passed"
            )
        |   Fail (Rejected (_err, _)) -> failwith "Admin -> Remove_space_manager - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"


// -- Send admin invitation --

// No amount 
let test_send_admin_invitation_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_admin = Test.nth_bootstrap_account 1 in

    let result = Test.transfer_to_contract contract (Admin (Send_admin_invitation ({new_admin = new_admin}))) 1tez in

    match result with
            Success _gas -> failwith "Admin -> Send_admin_invitation - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Send_admin_invitation - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    


// Not admin
let test_send_admin_invitation_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_admin = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract (Admin (Send_admin_invitation ({new_admin = new_admin}))) 0tez in

    match result with
            Success _gas -> failwith "Admin -> Send_admin_invitation - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Send_admin_invitation - Not admin : Should not work if not admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Success
let test_send_admin_invitation_success =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_admin = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Admin (Send_admin_invitation ({new_admin = new_admin}))) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                if Some (new_admin) = new_str.admin_str.pending_admin 
                then "Passed"
                else "Admin -> Send_admin_invitation - Success : This test should pass (error: wrong pending admin)"
            )
        |   Fail (Rejected (_err, _)) -> failwith "Admin -> Send_admin_invitation - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"  


// -- Revoke admin invitation --


// No amount 
let test_revoke_admin_invitation_no_amount =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let result = Test.transfer_to_contract contract (Admin (Revoke_admin_invitation ())) 1tez in

    match result with
            Success _gas -> failwith "Admin -> Revoke_admin_invitation - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Revoke_admin_invitation - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    


// Not admin
let test_revoke_admin_invitation_not_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let no_admin = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin in

    let result = Test.transfer_to_contract contract (Admin (Revoke_admin_invitation ())) 0tez in

    match result with
            Success _gas -> failwith "Admin -> Revoke_admin_invitation - Not admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Revoke_admin_invitation - Not admin : Should not work if not admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Success
let test_revoke_admin_invitation_success =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None: address option), true) in
    let contract = Test.to_contract contract_add  in

    let new_admin = Test.nth_bootstrap_account 1 in

    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Send_admin_invitation ({new_admin = new_admin}))) 0tez in

    let result = Test.transfer_to_contract contract (Admin (Revoke_admin_invitation ())) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                if Some(new_admin) = new_str.admin_str.pending_admin 
                then "Admin -> Revoke_admin_invitation - Success : This test should pass (error: wrong pending admin)"
                else "Passed"
            )
        |   Fail (Rejected (_err, _)) -> failwith "Admin -> Revoke_admin_invitation - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"  