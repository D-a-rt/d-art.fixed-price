#import "storage.test.mligo" "PM_STR"
#include "../../d-art.permission-manager/views.mligo"

// -- Is minter --

let test_is_minter =
    let minter = Test.nth_bootstrap_account 1 in
    let contract_add, _ = PM_STR. get_permission_manager_contract(Some (minter), true) in
    let strg = Test.get_storage contract_add in

    let not_minter = Test.nth_bootstrap_account 2 in

    let is_minter_true = is_minter (minter, strg) in
    let is_not_minter_false = is_minter (not_minter, strg) in

    let () = assert_with_error (is_minter_true = true) "Views - Is minter : This test should pass, correct minter specified" in
    let () = assert_with_error (is_not_minter_false = false) "Views - Is minter : This test should pass, uncorrect minter specified" in
    "Passed"
 
 
// -- Is space --

let test_is_space_manager =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None : address option), true) in
    let contract = Test.to_contract contract_add  in

    let space = Test.nth_bootstrap_account 1 in
    let not_space_manager = Test.nth_bootstrap_account 2 in
    
    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Add_space_manager (space))) 0tez in

    let strg = Test.get_storage contract_add in

    let is_space_manager_true = is_space_manager (space, strg) in
    let is_not_space_false = is_space_manager (not_space_manager, strg) in

    let () = assert_with_error (is_space_manager_true = true) "Views - Is space : This test should pass, correct space specified" in
    let () = assert_with_error (is_not_space_false = false) "Views - Is space : This test should pass, uncorrect space specified" in
    "Passed"


// -- Is admin --

let test_is_admin =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None : address option), true) in
    let contract = Test.to_contract contract_add  in

    
    let admin = Test.nth_bootstrap_account 0 in
    let not_admin = Test.nth_bootstrap_account 1 in

    let () = Test.set_source admin in

    let strg = Test.get_storage contract_add in

    let is_admin_true = is_admin (admin, strg) in
    let is_not_admin_false = is_admin (not_admin, strg) in

    let () = assert_with_error (is_admin_true = true) "Views - Is admin : This test should pass, correct admin specified" in
    let () = assert_with_error (is_not_admin_false = false) "Views - Is admin : This test should pass, uncorrect admin specified" in
    "Passed"
 
