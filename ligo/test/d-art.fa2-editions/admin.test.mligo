#import "storage.test.mligo" "FA2_STR"

// TEST FILE FOR ADMIN ENTRYPOINTS

// -- Pause numbered edition -- 

// Fail not admin 
let test_pause_numbered_edition_minting_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (PauseNumberedEditionMinting (true))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> PauseNumberedEditionMinting - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> PauseNumberedEditionMinting - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_pause_numbered_edition_minting_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (PauseNumberedEditionMinting (true))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> PauseNumberedEditionMinting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> PauseNumberedEditionMinting - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_pause_numbered_edition_minting =
    let contract_add, admin, _, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (PauseNumberedEditionMinting (true))) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.paused_nb_edition_minting = true) "Admin -> PauseNumberedEditionMinting - Success : This test should pass :  Wrong paused_nb_edition_minting" in
    "Passed"

// -- Pause minting --

// Fail not admin
let test_pause_minting_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (PauseMinting (true))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> PauseMinting - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> PauseMinting - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_pause_minting_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (PauseMinting (true))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> PauseMinting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> PauseMinting - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_pause_minting =
    let contract_add, admin, _, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (PauseMinting (true))) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.paused_minting = true) "Admin -> PauseMinting - Success : This test should pass :  Wrong paused_minting" in
    "Passed"


// -- Add Minter --

// Fail not admin
let test_add_minter_not_admin = 
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (AddMinter (owner1))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> AddMinter - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> AddMinter - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_add_minter_no_amount =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (AddMinter (owner1))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> AddMinter - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> AddMinter - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail already minter
let test_add_minter_already_minter =
    let contract_add, admin, _, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Admin (AddMinter (minter))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> AddMinter - Already minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_MINTER") ) "Admin -> AddMinter - Already minter : Should not work if already minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_add_minter =
    let contract_add, admin, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (AddMinter (owner1))) 0tez in

    let new_str = Test.get_storage contract_add in
    
    match Big_map.find_opt owner1 new_str.admin.minters with
            Some _ -> "Passed"
        |   None -> "Admin -> AddMinter - Success : This test should pass :  Minter not in big_map" 
    

// -- Remove minter --

// Fail if not admin
let test_remove_minter_not_admin = 
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (RemoveMinter (owner1))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> AddMinter - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> AddMinter - No amount : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_remove_minter_no_amount =
    let contract_add, _, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Admin (RemoveMinter (owner1))) 1tez in

    match result with
        Success _gas -> failwith "Admin -> RemoveMinter - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> RemoveMinter - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if not minter
let test_remove_minter_not_minter =
    let contract_add, admin, owner1, _ = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Admin (RemoveMinter (owner1))) 0tez in

    match result with
        Success _gas -> failwith "Admin -> RemoveMinter - Not minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTER_NOT_FOUND") ) "Admin -> RemoveMinter - Not minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_remove_minter =
    let contract_add, admin, _, minter = FA2_STR.get_initial_storage(false, false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (RemoveMinter (minter))) 0tez in

    let new_str = Test.get_storage contract_add in
    match Big_map.find_opt minter new_str.admin.minters with
            Some _ -> "Admin -> RemoveMinter - Success : This test should pass :  Minter already in big_map" 
        |   None -> "Passed"
    
