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
 
 
// -- Is gallery --

let test_is_gallery =
    let contract_add, _ = PM_STR. get_permission_manager_contract((None : address option), true) in
    let contract = Test.to_contract contract_add  in

    let gallery = Test.nth_bootstrap_account 1 in
    let not_gallery = Test.nth_bootstrap_account 2 in
    
    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Add_gallery (gallery))) 0tez in

    let strg = Test.get_storage contract_add in

    let is_gallery_true = is_gallery (gallery, strg) in
    let is_not_gallery_false = is_gallery (not_gallery, strg) in

    let () = assert_with_error (is_gallery_true = true) "Views - Is gallery : This test should pass, correct gallery specified" in
    let () = assert_with_error (is_not_gallery_false = false) "Views - Is gallery : This test should pass, uncorrect gallery specified" in
    "Passed"
 
