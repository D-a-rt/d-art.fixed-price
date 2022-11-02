#import "storage.test.mligo" "PM_STR"

// -- Accept admin invitation -- 

// No amount
let test_accept_admin_invitation_no_amount =
    let contract_add = PM_STR.get_initial_str(None: address option) in
    let contract = Test.to_contract contract_add  in

    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({accept = true})) 1tez in

    match result with
            Success _gas -> failwith "Accept_admin_invitation - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Accept_admin_invitation - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    


// Not a pending admin (no pending admin in storage)
let test_accept_admin_invitation_no_pending_admin = 
    let contract_add = PM_STR.get_initial_str(None: address option) in
    let contract = Test.to_contract contract_add  in

    let new_admin = Test.nth_bootstrap_account 1 in
    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({accept = true})) 0tez in

    match result with
            Success _gas -> failwith "Accept_admin_invitation - No pending admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_PENDING_ADMIN") ) "Accept_admin_invitation - No pending admin : Should not work if no pending admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"


// Not a pending admin (pending admin in storage)
let test_accept_admin_invitation_wrong_pending_admin = 
    let contract_add = PM_STR.get_initial_str(None: address option) in
    let contract = Test.to_contract contract_add  in

    let new_admin = Test.nth_bootstrap_account 1 in
    let admin = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract (Admin (Send_admin_invitation ({new_admin = new_admin}))) 0tez in
    
    let wrong_new_admin = Test.nth_bootstrap_account 2 in
    let () = Test.set_source wrong_new_admin in

    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({accept = true})) 0tez in

    match result with
            Success _gas -> failwith "Accept_admin_invitation - Wrong pending admin : This test should fail"
        |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_PENDING_ADMIN") ) "Accept_admin_invitation - Wrong pending admin : Should not work if wrong pending admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"


// Accept success
let test_accept_admin_invitation_accept_success = 
    let contract_add = PM_STR.get_initial_str(None: address option) in
    let contract = Test.to_contract contract_add  in

    let new_admin = Test.nth_bootstrap_account 1 in
    let admin = Test.nth_bootstrap_account 0 in
    
    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract (Admin (Send_admin_invitation ({new_admin = new_admin}))) 0tez in
    
    let () = Test.set_source new_admin in
    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({accept = true})) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                if new_str.admin.admin = new_admin && new_str.admin.pending_admin = (None : address option)
                then "Passed"
                else failwith "Accept_admin_invitation - Accept success : Wrong admin saved"
                
            )
        |   Fail (Rejected (err, _)) -> failwith "Accept_admin_invitation - Accept success : This test should fail"
        |   Fail _ -> failwith "Internal test failure"


// Refuse success
let test_accept_admin_invitation_refuse_success = 
    let contract_add = PM_STR.get_initial_str(None: address option) in
    let contract = Test.to_contract contract_add  in

    let new_admin = Test.nth_bootstrap_account 1 in
    let admin = Test.nth_bootstrap_account 0 in
    
    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract (Admin (Send_admin_invitation ({new_admin = new_admin}))) 0tez in
    
    let () = Test.set_source new_admin in
    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({accept = false})) 0tez in

    match result with
            Success _gas -> (
                let new_str = Test.get_storage contract_add in
                if new_str.admin.pending_admin = (None : address option) && new_str.admin.admin = admin
                then "Passed"
                else failwith "Accept_admin_invitation - Refuse success : Pending admin should be None and admin should be the same"
                
            )
        |   Fail (Rejected (err, _)) -> failwith "Accept_admin_invitation - Refuse success : This test should fail"
        |   Fail _ -> failwith "Internal test failure"
