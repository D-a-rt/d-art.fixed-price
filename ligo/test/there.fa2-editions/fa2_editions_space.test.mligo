#import "storage_space.test.mligo" "FA2_SPACE_STR"
#include "../../there.fa2-editions/compile_fa2_editions_space.mligo"

// -- Create proposal --

// Fail no amount
let test_space_factory_originated_create_proposal_no_amount =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if not admin
let test_space_factory_originated_create_proposal_not_admin =
    let contract_add, _, _, minter, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - not admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// fail if not minter
let test_space_factory_originated_create_proposal_not_minter =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in
    let not_minter = Test.nth_bootstrap_account 6 in

    let proposal_param = ([({
        minter = not_minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - not a minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_MINTER") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - not a minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// royalties more than 25 percent
let test_space_factory_originated_create_proposal_max_royalties =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 260n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - royalties more than 25% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_CANNOT_EXCEED_25_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - royalties more than 25% : Should not work if royalties more than 25%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// royalties minimum 5 percent
let test_space_factory_originated_create_proposal_min_royalties =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 40n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - royalties less than 5% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_MINIMUM_5_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - royalties less than 5% : Should not work if royalties less than 5%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// commissions cannot exceed 50 percent
let test_space_factory_originated_create_proposal_max_commissions =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 240n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 510n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - commissions more than 50% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "COMMISSIONS_CANNOT_EXCEED_50_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - commissions more than 50% : Should not work if commissions more than 50%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// edition number should be at least one
let test_space_factory_originated_create_proposal_min_edition_number =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 0n;
        royalty = 240n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - Min edition number : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - Min edition number : Should not work if edition number is smaller than 1" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// edition run too large
let test_space_factory_originated_create_proposal_max_edition_number =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 51n;
        royalty = 240n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - Max edition number : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_RUN_TOO_LARGE") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - Max edition number : Should not work if edition number is bigger than 50" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// total split
let test_space_factory_originated_create_proposal_total_split_smaller =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 240n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - Total split smaller: This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - Total split smaller : Should not work if total split not equal to 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// total split
let test_space_factory_originated_create_proposal_total_split_bigger =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 240n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = space;
            pct = 600n;
        }] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - Total split bigger : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - Total split bigger : Should not work if total split not equal to 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure" 

// total commission split
let test_space_factory_originated_create_proposal_total_commission_split_smaller =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 240n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 500n;
        space_commission_splits = ([{
            address = space;
            pct = 600n;
        }] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - Total commission split smaller: This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_COMMISSION_SPLIT_MUST_BE_100_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - Total commission split smaller : Should not work if total commission split not equal to 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// total commission split
let test_space_factory_originated_create_proposal_total_commission_split_bigger =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 240n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 500n;
        space_commission_splits = ([{
            address = space;
            pct = 600n;
        }; {
            address = minter;
            pct = 600n;
        }] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - Total commission split bigger: This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_COMMISSION_SPLIT_MUST_BE_100_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Create_proposals - Total commission split bigger : Should not work if total commission split not equal to 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Succces
let test_space_factory_originated_create_proposal_total_commission_success =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let result = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_strg = Test.get_storage contract_add in
            match Big_map.find_opt 0n new_strg.mint_proposals with
                    None -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - Success : Proposal should be saved in big map"
                |   Some _ -> "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"    


// -- Update proposal --

// Fail no amount
let test_space_factory_originated_update_proposal_no_amount =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if not admin
let test_space_factory_originated_update_proposal_not_admin =
    let contract_add, _, _, minter, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Create_proposals - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - not admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// royalties more than 25 percent
let test_space_factory_originated_update_proposal_max_royalties =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 260n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - royalties more than 25% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_CANNOT_EXCEED_25_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - royalties more than 25% : Should not work if royalties more than 25%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// royalties minimum 5 percent
let test_space_factory_originated_update_proposal_min_royalties =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 40n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - royalties less than 5% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ROYALTIES_MINIMUM_5_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - royalties less than 5% : Should not work if royalties less than 5%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// commissions cannot exceed 50 percent
let test_space_factory_originated_update_proposal_max_commissions =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 60n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 600n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - commissions more than 50% : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "COMMISSIONS_CANNOT_EXCEED_50_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - commissions more than 50% : Should not work if commissions more than 50%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// edition number should be at least one
let test_space_factory_originated_update_proposal_min_edition_number =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 0n;
        royalty = 60n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Min edition number : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_NUMBER_SHOULD_BE_AT_LEAST_ONE") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - Min edition number : Should not work if edition number is smaller than 1" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// edition run too large
let test_space_factory_originated_update_proposal_max_edition_number =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 65n;
        royalty = 60n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Max edition number : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "EDITION_RUN_TOO_LARGE") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - Max edition number : Should not work if edition number is bigger than 50" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// total split
let test_space_factory_originated_update_proposal_total_split_smaller =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 5n;
        royalty = 60n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Total split smaller: This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - Total split smaller : Should not work if total split not equal to 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// total split
let test_space_factory_originated_update_proposal_total_split_bigger =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 5n;
        royalty = 60n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = space;
            pct = 600n;
        }] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Total split bigger : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_SPLIT_MUST_BE_100_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - Total split bigger : Should not work if total split not equal to 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure" 

// total commission split
let test_space_factory_originated_update_proposal_total_commission_split_smaller =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 5n;
        royalty = 60n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 500n;
        space_commission_splits = ([{
            address = space;
            pct = 600n;
        }] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Total commission split smaller: This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_COMMISSION_SPLIT_MUST_BE_100_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - Total commission split smaller : Should not work if total commission split not equal to 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// total commission split
let test_space_factory_originated_update_proposal_total_commission_split_bigger =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 5n;
        royalty = 60n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 500n;
        space_commission_splits = ([{
            address = space;
            pct = 600n;
        }; {
            address = minter;
            pct = 600n;
        }] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Total commission split bigger: This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOTAL_COMMISSION_SPLIT_MUST_BE_100_PERCENT") ) "Admin (Space factory originated fa2 contract) -> Update_proposals - Total commission split bigger : Should not work if total commission split not equal to 100%" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Succces
let test_space_factory_originated_update_proposal_total_commission_success =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let update_proposal_param = ({
        proposal_id = 0n;
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 5n;
        royalty = 200n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.update_pre_mint_edition_param ) in

    let result = Test.transfer_to_contract contract ((Update_proposal (update_proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_strg = Test.get_storage contract_add in
            match Big_map.find_opt 0n new_strg.mint_proposals with
                    None -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Success : Proposal should be saved in big map"
                |   Some new_meta -> (
                    if new_meta.royalty = 200n
                    then "Passed"
                    else failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Success : Proposal should be updated"
                ) 
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Update_proposals - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"    

// -- Remove proposal --

// fail no amount
let test_space_factory_originated_remove_proposal_no_amount =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Remove_proposals ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_proposals - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Remove_proposals - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// fail if not admin
let test_space_factory_originated_remove_proposal_not_admin =
    let contract_add, _, _, minter, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract ((Remove_proposals ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_proposals - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Remove_proposals - not admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_space_factory_originated_remove_proposal_success =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 3n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([] : split list);
        space_commission = 500n;
        space_commission_splits = ([] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    
    let result = Test.transfer_to_contract contract ((Remove_proposals ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_strg = Test.get_storage contract_add in
            match Big_map.find_opt 0n new_strg.mint_proposals with
                    None -> "Passed"
                |   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Remove_proposals - Success : Proposal should be removed from the big map"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Remove_proposals - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"    

// -- Mint editions --

// fail no amount
let test_space_factory_originated_mint_editions_no_amount =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let result = Test.transfer_to_contract contract ((Mint_editions ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Mint_editions - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// fail if minter not sender
let test_space_factory_originated_mint_editions_minter_is_not_sender =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let _gas = Test.transfer_to_contract_exn contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let () = Test.set_source new_minter in

    let _gas = Test.transfer_to_contract_exn contract (Accept_minter_invitation ({accept = True}) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    let result = Test.transfer_to_contract contract ((Mint_editions ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - minter is not sender : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SENDER_MUST_BE_MINTER") ) "Admin (Space factory originated fa2 contract) -> Mint_editions - minter is not sender : Should not work if minter is not sender" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// fail if proposal undefined
let test_space_factory_originated_mint_editions_proposal_undefined =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Mint_editions ([({proposal_id = 12n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - proposal undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_PROPOSAL_UNDEFINED") ) "Admin (Space factory originated fa2 contract) -> Mint_editions - proposal undefined : Should not work if minter is not sender" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success
let test_space_factory_originated_mint_editions_success =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Mint_editions ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            if new_str.next_edition_id = 1n
            then (
                let () = match Big_map.find_opt 0n new_str.mint_proposals with
                        None -> unit 
                    |   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - success : Proposal should be deleted from mint proposals big_map"
                in
                let () = match Big_map.find_opt 0n new_str.editions_metadata with
                        None -> failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - success : Token has not been minted"
                    |   Some meta -> (
                        if meta.minter = minter
                        then unit
                        else failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - success : Wrong minter"
                    )
                in
                match Big_map.find_opt 0n new_str.assets.ledger with
                        None -> failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - success : Token has not been minted properly"
                    |   Some owner -> (
                        if owner = minter
                        then "Passed"
                        else failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - success : Wrong owner (minter should be owner)"
                    )
            )
            else failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - success : next_token_id should be incremented "
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Mint_editions - success : This test should pass "
    |   Fail _ -> failwith "Internal test failure"

// -- Reject proposal --

// fail no amount
let test_space_factory_originated_reject_proposals_no_amount =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let result = Test.transfer_to_contract contract ((Reject_proposals ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Reject_proposals - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Reject_proposals - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// fail proposal undefined
let test_space_factory_originated_reject_proposals_proposal_undefined =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Reject_proposals ([({proposal_id = 12n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Reject_proposals - proposal undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_PROPOSAL_UNDEFINED") ) "Admin (Space factory originated fa2 contract) -> Reject_proposals - proposal undefined : Should not work if minter is not sender" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// fail sender must be minter
let test_space_factory_originated_reject_proposals_sender_is_not_minter =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 50n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let () = Test.set_source space in
    let new_minter = Test.nth_bootstrap_account 9 in

    let _gas = Test.transfer_to_contract_exn contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let () = Test.set_source new_minter in

    let _gas = Test.transfer_to_contract_exn contract (Accept_minter_invitation ({accept = True}) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let () = Test.set_source space in
    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let () = Test.set_source new_minter in
    let result = Test.transfer_to_contract contract ((Reject_proposals ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Reject_proposals - minter is not sender : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SENDER_MUST_BE_MINTER") ) "Admin (Space factory originated fa2 contract) -> Reject_proposals - minter is not sender : Should not work if minter is not sender" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success
let test_space_factory_originated_reject_proposals_success =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Reject_proposals ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
           
            let () = match Big_map.find_opt 0n new_str.mint_proposals with
                    None -> unit 
                |   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Reject_proposals - success : Proposal should be deleted from mint proposals big_map"
            in
            let () = match Big_map.find_opt 0n new_str.editions_metadata with
                    None -> unit
                |   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Reject_proposals - success : Token should not be minted"
            in
            match Big_map.find_opt 0n new_str.assets.ledger with
                    None -> "Passed"
                |   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Reject_proposals - success : Token should not be minted"
        
        )
    |   Fail (Rejected (_err, _)) ->  failwith "Admin (Space factory originated fa2 contract) -> Reject_proposals - success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"


// -- Upgrade License

// no amount
let test_space_factory_originated_upgrade_license_no_amount =
    let contract_add, _, _, minter, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = True; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 1tez in

    match result with
        Success _gas -> failwith "Upgrade_license (Space originated fa2 contract) - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Upgrade_license (Space originated fa2 contract) - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// token undefined
let test_space_factory_originated_upgrade_license_token_undefined =
    let contract_add, _, _, minter, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 10000n; license = {upgradeable = True; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Upgrade_license (Space originated fa2 contract) - Token undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_TOKEN_UNDEFINED") ) "Upgrade_license (Space originated fa2 contract) - Token undefined : Should not work if token undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// sender must be minter 
let test_space_factory_originated_upgrade_license_sender_must_be_minter =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 150n;
        license = {
            upgradeable = True;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let () = Test.set_source minter in
    let _gas = Test.transfer_to_contract_exn contract ((Mint_editions ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    
    let () = Test.set_source space in
    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = True; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Upgrade_license (Space originated fa2 contract) - Sender must be minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SENDER_MUST_BE_MINTER") ) "Upgrade_license (Space originated fa2 contract) - Sender must be minter : Should not work if sender is not minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// license sealed
let test_space_factory_originated_upgrade_license_sealed =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 150n;
        license = {
            upgradeable = True;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let () = Test.set_source minter in
    let _gas = Test.transfer_to_contract_exn contract ((Mint_editions ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let _gas = Test.transfer_to_contract_exn contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = False; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in
    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = True; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> failwith "Upgrade_license (Space originated fa2 contract) - License sealed : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "LICENSE_SEALED") ) "Upgrade_license (Space originated fa2 contract) - License sealed : Should not work if the license is sealed" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_space_factory_originated_upgrade_license_success =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 150n;
        license = {
            upgradeable = True;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : split list);
        space_commission = 300n;
        space_commission_splits = ([{
            address = space;
            pct = 1000n;
        };] : split list);
    } : FA2_SPACE_STR.pre_mint_edition_param )] : FA2_SPACE_STR.pre_mint_edition_param list ) in

    let _gas = Test.transfer_to_contract contract ((Create_proposals (proposal_param)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
        
    let () = Test.set_source minter in
    let _gas = Test.transfer_to_contract_exn contract ((Mint_editions ([({proposal_id = 0n} : FA2_SPACE_STR.proposal_param)])) : FA2_SPACE_STR.editions_entrypoints) 0tez in


    let result = Test.transfer_to_contract contract (Upgrade_license (({ edition_id = 0n; license = {upgradeable = False; hash = ("54657374206d65737361676520746574657465746567" : bytes)} } : license_param)) : editions_entrypoints ) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            
            let () = match Big_map.find_opt 0n new_str.editions_metadata with 
                    Some edition_metadata -> assert_with_error (edition_metadata.license = {upgradeable = False; hash = ("54657374206d65737361676520746574657465746567" : bytes)}) "Upgrade_license (Space originated fa2 contract) - Success : License should be upgraded"
                |   None -> failwith "Upgrade_license (Space originated fa2 contract) - Success : Token should exist"
            in

            "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Upgrade_license (Space originated fa2 contract) - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"
