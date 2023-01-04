#import "storage.test.mligo" "FA2_STR"
#import "storage_serie.test.mligo" "FA2_SERIE_STR"
#import "storage_gallery.test.mligo" "FA2_GALLERY_STR"

#import "../../d-art.fa2-editions/views.mligo" "FA2_V"
#import "../../d-art.fa2-editions/interface.mligo" "FA2_I"

// Test on views are only meant to check the success as it's not possible to 
// catch a failwith while testing a view using the Ligo Test API (I might have missed it)

// -- Is token minter --

let test_is_token_minter_view =
    let contract_t_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_t_add in 

    let is_minter = FA2_V.is_token_minter ((minter, 0n : address * FA2_I.token_id), strg) in

    match is_minter with
        | Some is_m -> (
            let () = assert_with_error (is_m) "Views - Is token minter : This test should pass, correct minter specified" in
            "Passed"
        )
        | None -> "Views - Is token minter : This test should pass, correct minter specified"


let test_is_token_minter_view_false =
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let not_minter = Test.nth_bootstrap_account 6 in
    let is_minter = FA2_V.is_token_minter ((not_minter, 0n : address * FA2_I.token_id ), strg) in

    match is_minter with
        | Some is_m -> (
            let () = assert_with_error (is_m <> true) "Views - Is token minter : This test should pass, wrong minter specified" in
            "Passed"
        )
        | None -> "Views - Is token minter : This test should pass, wrong minter specified"

// -- Minter --

// Success
let test_minter_view =
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let minter_address = FA2_V.minter (1n, strg) in

    match minter_address with
        | Some minter_add -> (
            let () = assert_with_error (minter_add = minter) "Views - Minter : This test should pass, wrong minter specified" in
            "Passed"
        )
        | None -> "Views - Minter : This test should pass, wrong minter specified"

// -- Views - royalty --
// Success
let test_royalty_view =
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let royalty = FA2_V.royalty (1n, strg) in

    match royalty with
        | Some r -> (
            let () = assert_with_error (r = 150n) "Views - Royalty : This test should pass, wrong royalty specified" in
            "Passed"
        )
        | None -> "Views - Royalty : This test should pass, wrong royalty specified"


// -- Views - royalty splits --
// Success
let test_royalty_splits_view =
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let royalties = FA2_V.royalty_splits (1n, strg) in

    let roy = ({
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )]
    } : FA2_V.royalties) in

    match royalties with
        | Some r -> (
            let () = assert_with_error (r = roy) "Views - Royalty splits : This test should pass, wrong royalties specified" in
            "Passed"
        )
        | None -> "Views - Royalty splits : This test should pass, wrong royalties specified"


// -- Views - splits --
// Success
let test_splits_view =
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let splits = FA2_V.splits (1n, strg) in

    let spts = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )] in

    match splits with
        | Some s -> (
            let () = assert_with_error (s = spts) "Views - Splits : This test should pass, wrong splits specified" in
            "Passed"
        )
        | None -> "Views - Splits : This test should pass, wrong splits specified"


// -- Views - royalty distribution --
// Success
let test_royalty_distribution_view =
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let distribution = FA2_V.royalty_distribution (1n, strg) in

    let distri = (minter, ({
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )]
    } : FA2_V.royalties)) in

    match distribution with
        | Some d -> (
            let () = assert_with_error (d = distri) "Views - Splits : This test should pass, wrong royalti distribution specified" in
            "Passed"
        )
        | None -> "Views - Splits : This test should pass, wrong royalti distribution specified"


// -- Views - token metadata --
// Success
let test_token_metadata_view =
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let token_metadata = FA2_V.token_metadata (1n, strg) in

    let token_m = ({
        token_id = 1n;
        token_info = Map.literal [(("edition_number"), Bytes.pack(2n)); (("license") , ("ff7a7aff" : bytes)) ]
    } : FA2_V.token_metadata) in

    match token_metadata with
        | Some tm -> (
            let () = assert_with_error (tm = token_m) "Views - Token metadata : This test should pass, wrong token_metadata" in
            "Passed"
        )
        | None -> "Views - Token metadata : This test should pass, wrong token_metadata"


// -- Views - is token unique edition --
// Success
let test_is_unique_edition =
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let is_unique_edition = FA2_V.is_unique_edition(1n, strg) in

    match is_unique_edition with
        | Some is_un -> (
            let () = assert_with_error (is_un = false) "Views - Is unique edition : This test should pass, test is unique edition" in
            "Passed"
        )
        | None -> "Views - Is unique edition : This test should pass, test is unique edition"


// -- FA2 editions version originated from Serie factory contract

// -- Is minter --

let test_serie_factory_originated_is_token_minter_view =
    let contract_t_add, _, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let strg = Test.get_storage contract_t_add in 

    let is_minter = FA2_SERIE_STR.is_token_minter ((minter, 0n : address * FA2_I.token_id), strg) in

    match is_minter with
        | Some is_m -> (
            let () = assert_with_error (is_m) "Views - Is minter : This test should pass, correct minter specified" in
            "Passed"
        )
        | None -> "Views - Is minter : This test should pass, correct minter specified"


let test_serie_factory_originated_is_token_minter_view_false =
    let contract_add, _, _, _ = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let strg = Test.get_storage contract_add in

    let not_minter = Test.nth_bootstrap_account 6 in
    let is_minter = FA2_SERIE_STR.is_token_minter ((not_minter, 0n : address * FA2_I.token_id ), strg) in

    match is_minter with
        | Some is_m -> (
            let () = assert_with_error (is_m <> true) "Views - Is minter : This test should pass, wrong minter specified" in
            "Passed"
        )
        | None -> "Views - Is minter : This test should pass, wrong minter specified"


// -- Minter --

// Success
let test_serie_factory_originated_minter_view =
    let contract_add, _, _, minter_add = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let strg = Test.get_storage contract_add in

    let minter_address = FA2_SERIE_STR.minter (1n, strg) in

    let () = assert_with_error (minter_address = minter_add) "Views - Minter : This test should pass, wrong minter specified" in
    "Passed"
    

// -- Views - royalty distribution --

// Success
let test_serie_factory_originated_royalty_distribution_view =
    let contract_add, _, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let strg = Test.get_storage contract_add in

    let distribution = FA2_SERIE_STR.royalty_distribution (1n, strg) in

    let distri = (minter, ({
        royalty = 150n;
        splits = [({
            address = minter;
            pct = 1000n;
        } : FA2_I.split )]
    } : FA2_V.royalties)) in

    match distribution with
        | Some d -> (
            let () = assert_with_error (d = distri) "Views - Splits : This test should pass, wrong distri specified" in
            "Passed"
        )
        | None -> "Views - Is minter : This test should pass, wrong distri specified"


// -- FA2 editions version originated from Gallery factory contract

let test_gallery_factory_originated_commission_splits = 
    let contract_add, _, _, minter, gallery = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let proposal_param = ([({
        minter = minter;
        edition_info = ("" : bytes);
        total_edition_number = 1n;
        royalty = 150n;
        license = {
            upgradeable = False;
            hash = ("ff7a7aff" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 1000n;
        }] : FA2_I.split list);
        gallery_commission = 300n;
        gallery_commission_splits = ([{
            address = gallery;
            pct = 1000n;
        };] : FA2_I.split list);
    } : FA2_GALLERY_STR.pre_mint_edition_param )] : FA2_GALLERY_STR.pre_mint_edition_param list ) in

    let () = Test.set_source gallery in
    let _gas = Test.transfer_to_contract_exn contract ((Create_proposals (proposal_param)) : FA2_GALLERY_STR.editions_entrypoints) 0tez in
    
    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Mint_editions ([({proposal_id = 0n} : FA2_GALLERY_STR.proposal_param)])) : FA2_GALLERY_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            let commission_distribution = FA2_GALLERY_STR.commission_splits (0n, new_str) in

            let commission_distri = ({
                commission_pct = 300n;
                splits = [({
                    address = gallery;
                    pct = 1000n;
                } : FA2_I.split )]
            } : FA2_V.commissions) in

            match commission_distribution with
                | Some cd -> (
                    let () = assert_with_error (cd = commission_distri) "Views Gallery - Commissions Splits : This test should pass " in
                    "Passed"
                )
                | None -> "Views - Is minter : This test should pass, wrong distri specified"
        )
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_PROPOSAL_UNDEFINED") ) "Admin (Gallery factory originated fa2 contract) -> Mint_editions - success : Should not work if minter is not sender" in
            "Failed"
        )
    |   Fail _ -> failwith "Internal test failure"

let test_token_metadata_view_symbol =
    let t_fa2_gallery_add, _, _, _ = FA2_GALLERY_STR.get_fa2_editions_gallery_contract_fixed_price(("KT1DHceF5q3wuxBLAb6iYiocddpWv71A3Nhd" : address)) in
    let strg = Test.get_storage t_fa2_gallery_add in

    let token_metadata = FA2_GALLERY_STR.token_metadata (0n, strg) in

    let token_m = ({
        token_id = 0n;
        token_info = Map.literal [(("symbol"), ("4a3a504e" : bytes)); (("license") , ("ff7a7aff" : bytes)); (("edition_number"), Bytes.pack(1n));]
    } : FA2_GALLERY_STR.token_metadata) in

    match token_metadata with
        | Some tm -> (
            let () = assert_with_error (tm = token_m) "Views - Token metadata : This test should pass, wrong token_metadata for gallery FA2" in
            "Passed"
        )
        | None -> "Views - Token metadata : This test should pass, wrong token_metadata for gallery FA2"
