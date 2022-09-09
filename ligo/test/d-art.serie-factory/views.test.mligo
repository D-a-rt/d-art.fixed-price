#import "storage.test.mligo" "FA2_STR"
#include "../../d-art.serie-factory/views.mligo"

// -- Is minter --

let test_is_minter =
    let contract_address, admin = FA2_STR.get_factory_contract() in
    let contract_add : (art_serie_factory, serie_factory_storage) typed_address = Test.cast_address contract_address in
    let contract = Test.to_contract contract_add in
    let strg = Test.get_storage contract_add in

    let minter = Test.nth_bootstrap_account 2 in
    let not_minter = Test.nth_bootstrap_account 3 in

    let is_minter_true = is_minter (minter, strg) in
    let is_not_minter_false = is_minter (not_minter, strg) in

    let () = assert_with_error (is_minter_true = true) "Views - Is minter : This test should pass, correct minter specified" in
    let () = assert_with_error (is_not_minter_false = false) "Views - Is minter : This test should pass, uncorrect minter specified" in
    "Passed"
 