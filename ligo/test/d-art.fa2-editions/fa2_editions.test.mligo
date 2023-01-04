#import "storage.test.mligo" "FA2_STR"
#include "../../d-art.fa2-editions/multi_nft_token_editions.mligo" 

// -- Burn Token --

// Fail no amount
let test_burn_token_no_amount = 
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Burn_token (1n)) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Burn_token - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Burn_token - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if not owner
let test_burn_token_not_owner = 
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Burn_token (3n)) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Burn_token - Not owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_INSUFFICIENT_BALANCE") ) "Burn_token - Not owner : Should not work if not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if operator
let test_burn_token_if_operator = 
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let operator1 = Test.nth_bootstrap_account 4 in
    let () = Test.set_source operator1 in

    let result = Test.transfer_to_contract contract ((Burn_token (1n)) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Burn_token - Is operator : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_INSUFFICIENT_BALANCE") ) "Burn_token - Is operator : Should not work if sender is an operator" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Fail if token undefined
let test_burn_token_token_undefined = 
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Burn_token (9879n)) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Burn_token - Token undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_TOKEN_UNDEFINED") ) "Burn_token - Token undefined : Should not work if token undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success - should remove the token from the ledger_big map
let test_burn_token_token_undefined = 
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let _gas = Test.transfer_to_contract_exn contract ((Burn_token (1n)) : editions_entrypoints) 0tez in

    let new_strg = Test.get_storage contract_add in
    match Big_map.find_opt 1n new_strg.assets.ledger with
            Some _ -> failwith "Burn_token - Success : Token should be remove from the ledger"
        |   None -> "Passed"

// -- Create Proposal --

// no amount
let test_create_proposal_no_amount = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Create_proposal - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Create_proposal - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// minting paused
let test_create_proposal_minting_paused =
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(true) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    match result with
            Success _gas -> failwith "Create_proposal - Minting closed : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTING_PAUSED") ) "Create_proposal - Minting closed : Should not work if minting is paused" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"

// not minter
let test_create_proposal_not_minter = 
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Create_proposal - Not a minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_MINTER") ) "Create_proposal - Not a minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// already minted
let test_create_proposal_already_minted = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    match result with
            Success _gas -> (
                let () = Test.set_source admin in
                let _gas = Test.transfer_to_contract_exn contract ((Admin (Accept_proposals ([{proposal_id = 1n}]) : admin_entrypoints )) : editions_entrypoints) 0tez in

                let () = Test.set_source minter in
                let _gas = Test.transfer_to_contract_exn contract ((Mint_editions {proposal_id = 1n}) : editions_entrypoints) 0tez in
                let result_2 = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in
                
                match result_2 with
                        Success _gas -> failwith "Create_proposal - Already minted : This test should fail"
                    |   Fail (Rejected (err, _)) ->  (
                            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_MINTED") ) "Create_proposal - Already minted : Should not work if minter already created on this contract" in
                            "Passed"
                        )
                    |   Fail _ -> failwith "Internal test failure"

            )
        |   Fail (Rejected (_err, _)) -> failwith "Create_proposal - Already minted : First proposal should pass"
        |   Fail _ -> failwith "Internal test failure"


// royalties exceed 25 percent
let test_create_proposal_exceed_25_pct = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 251n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Create_proposal - Royalties > 25% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_CANNOT_EXCEED_25_PERCENT") ) "Create_proposal - Royalties > 25% : Should not work if royalties exceed 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// total split 100 pct
let test_create_proposal_split_100_pct = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 501n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let () = match result with
            Success _gas -> failwith "Create_proposal - Splits != 100% : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Create_proposal - Splits > 100% : Should not work if Splits exceed 100%" in
                ()
            )
        |   Fail _ -> failwith "Internal test failure"
    in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 499n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Create_proposal - Splits != 100% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Create_proposal - Splits < 100% : Should not work if Splits lower then 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_create_proposal_success = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            match Big_map.find_opt 1n new_str.proposals with 
                    Some proposal -> (
                        let () = assert_with_error (proposal.minter = minter) "Create_proposal - No receivers : Receiver should be minter" in
                        let () = assert_with_error (proposal.royalty = 100n) "Create_proposal - No receivers : Wring royalties" in
                        let () = assert_with_error (proposal.splits = ([{
                                address = minter;
                                pct = 500n;
                            }; {
                                address = admin;
                                pct = 500n;
                            }] : split list )) "Create_proposal - No receivers : Wring royalties" 
                        in
                        "Passed"
                    ) 
                |   None -> failwith "Create_proposal - No receivers : Token should exist"
            
        )
    |   Fail (Rejected (_err, _)) -> failwith "Create_proposal - No receivers : This test should pass"
    |   Fail _ -> failwith "Internal test failure"


// -- Update Proposal --

// no amount
let test_update_proposal_no_amount = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let update_mint_edition_param = ({
        proposal_id = 1n;
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : update_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal update_mint_edition_param) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Update_proposal - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Update_proposal - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// not minter
let test_update_proposal_not_minter = 
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let update_mint_edition_param = ({
        proposal_id = 1n;
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : update_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal update_mint_edition_param) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Update_proposal - Not a minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_MINTER") ) "Update_proposal - Not a minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// royalties exceed 25 percent
let test_update_proposal_exceed_25_pct = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 250n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let update_mint_edition_param = ({
        proposal_id = 1n;
        edition_info = ("" : bytes);
        royalty = 251n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : update_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal update_mint_edition_param) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Update_proposal - Royalties > 25% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_CANNOT_EXCEED_25_PERCENT") ) "Update_proposal - Royalties > 25% : Should not work if royalties exceed 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// total split 100 pct
let test_update_proposal_split_100_pct = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let update_mint_edition_param = ({
        proposal_id = 1n;
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 501n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : update_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal update_mint_edition_param) : editions_entrypoints) 0tez in

    let () = match result with
            Success _gas -> failwith "Update_proposal - Splits != 100% : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Update_proposal - Splits > 100% : Should not work if Splits exceed 100%" in
                ()
            )
        |   Fail _ -> failwith "Internal test failure"
    in

    let update_mint_edition_param_2 = ({
        proposal_id = 1n;
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 499n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : update_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal update_mint_edition_param_2) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Update_proposal - Splits != 100% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Update_proposal - Splits < 100% : Should not work if Splits lower then 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// success
let test_update_proposal_success = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let update_mint_edition_param = ({
        proposal_id = 1n;
        edition_info = ("2134" : bytes);
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = minter;
            pct = 500n;
        }] : split list );
    } : update_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal update_mint_edition_param) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            match Big_map.find_opt 1n new_str.proposals with 
                    Some proposal -> (
                        let () = assert_with_error (proposal.minter = minter) "Update_proposal - No receivers : Receiver should be minter" in
                        let () = assert_with_error (proposal.royalty = 150n) "Update_proposal - No receivers : Wring royalties" in
                        let () = assert_with_error (proposal.splits = ([{
                                address = minter;
                                pct = 500n;
                            }; {
                                address = minter;
                                pct = 500n;
                            }] : split list )) "Update_proposal - No receivers : Wring royalties" 
                        in
                        "Passed"
                    ) 
                |   None -> failwith "Update_proposal - No receivers : Token should exist"
            
        )
    |   Fail (Rejected (_err, _)) -> failwith "Update_proposal - No receivers : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// -- Remove Proposal --

// no amount
let test_remove_proposal_no_amount = 
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract ((Remove_proposal {proposal_id = 1n}) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Remove_proposal - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Remove_proposal - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// proposal undefined
let test_remove_proposal_undefined =
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract ((Remove_proposal {proposal_id = 1n}) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Remove_proposal - Proposal undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_PROPOSAL_UNDEFINED") ) "Remove_proposal - Proposal undefined : Should not work if proposal undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// sender_must_be_minter
let test_remove_proposal_sender_must_be_sender =
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Remove_proposal {proposal_id = 1n}) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Remove_proposal - Sender must be sender : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SENDER_MUST_BE_MINTER") ) "Remove_proposal - Sender must be sender : Should not work if sender is not minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_remove_proposal_success = 
  let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let result = Test.transfer_to_contract contract ((Remove_proposal {proposal_id = 1n}) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            match Big_map.find_opt 1n new_str.proposals with 
                    Some _ -> failwith "Remove_proposal - Success : Proposal should be removed"
                |   None -> "Passed"
            
        )
    |   Fail (Rejected (_err, _)) -> (
            failwith "Remove_proposal - No receivers : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"

// -- Mint editions --

// no amount
let test_mint_edition_no_amount = 
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract ((Mint_editions {proposal_id = 1n}) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Mint_editions - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Mint_editions - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// proposal undefined
let test_mint_edition_proposal_undefined = 
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract ((Mint_editions {proposal_id = 1n}) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Proposal undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_PROPOSAL_UNDEFINED") ) "Mint_editions - Proposal undefined : Should not work if proposal is undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// proposal need to be accepted
let test_mint_edition_proposal_not_accepted = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let result = Test.transfer_to_contract contract ((Mint_editions {proposal_id = 1n}) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Proposal not accepted : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PROPOSAL_NEED_TO_BE_ACCEPTED") ) "Mint_editions - Proposal not accepted : Should not work if proposal not accepted" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// sender must be minter
let test_mint_edition_proposal_not_accepted = 
    let contract_add, admin, owner1, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract ((Admin (Accept_proposals ([{proposal_id = 1n}]) : admin_entrypoints )) : editions_entrypoints) 0tez in

    let () = Test.set_source owner1 in
    let result = Test.transfer_to_contract contract ((Mint_editions {proposal_id = 1n}) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Mint_editions - Sender must be minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SENDER_MUST_BE_MINTER") ) "Mint_editions - Sender must be minter : Should not work if sender is not minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_mint_edition_proposal_not_accepted = 
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract ((Admin (Accept_proposals ([{proposal_id = 1n}]) : admin_entrypoints )) : editions_entrypoints) 0tez in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Mint_editions {proposal_id = 1n} ) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            match Big_map.find_opt 50n new_str.assets.ledger with 
                    Some add -> (
                        let () = assert_with_error (add = minter) "Mint_editions - Success : Receiver should be minter" in
                        "Passed"
                    ) 
                |   None -> failwith "Mint_editions - Success : Token should exist"
            
        )
    |   Fail (Rejected (_err, _)) -> (
            failwith "Mint_editions - Success : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"


// -- Update Metadata

// Fail if not admin
let test_update_metadata_no_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract (Update_metadata ("54657374206d657373616765207465746574657465" : bytes) : editions_entrypoints ) 0tez in

    match result with
            Success _gas -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Update_metadata (Serie originated fa2 contract) - Update metadata : Should not work if not an admin" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"
      
let test_update_metadata_success =
    let contract_add, admin, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract (Update_metadata ("54657374206d65737361676520746574657465746567" : bytes) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            let () = match Big_map.find_opt "" new_str.metadata with 
                    Some meta -> assert_with_error (meta = ("54657374206d65737361676520746574657465746567" : bytes)) "Update_metadata (Serie originated fa2 contract) - Update metadata success : Metadata shoule be updated"
                |   None -> failwith "Update_metadata (Serie originated fa2 contract) - Update metadata : Metadata should exist"
            in
            "Passed"
        )
    |   Fail (Rejected (_err, _)) -> (
            failwith "Update_metadata (Serie originated fa2 contract) - Update metadata success : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"
