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

    let () = assert_with_error (is_minter) "Views - Is token minter : This test should pass, correct minter specified" in
    "Passed"


let test_is_token_minter_view_false =
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let not_minter = Test.nth_bootstrap_account 6 in
    let is_minter = FA2_V.is_token_minter ((not_minter, 0n : address * FA2_I.token_id ), strg) in

    let () = assert_with_error (is_minter <> true) "Views - Is token minter : This test should pass, wrong minter specified" in
    "Passed"

// -- Minter --

// Success
let test_minter_view =
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let minter_address = FA2_V.minter (1n, strg) in

    let () = assert_with_error (minter_address = minter) "Views - Minter : This test should pass, wrong minter specified" in
    "Passed"

// -- Views - royalty --
// Success
let test_royalty_view =
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let royalty = FA2_V.royalty (1n, strg) in

    let () = assert_with_error (royalty = 150n) "Views - Royalty : This test should pass, wrong royalty specified" in
    "Passed"


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

    let () = assert_with_error (royalties = roy) "Views - Royalty splits : This test should pass, wrong minter specified" in
    "Passed"


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

    let () = assert_with_error (splits = spts) "Views - Splits : This test should pass, wrong minter specified" in
    "Passed"


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

    let () = assert_with_error (distribution = distri) "Views - Splits : This test should pass, wrong minter specified" in
    "Passed"

// -- Views - token metadata --
// Success
let test_token_metadata_view =
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let token_metadata = FA2_V.token_metadata (1n, strg) in

    let token_m = ({
        token_id = 1n;
        token_info = Map.literal [("edition_number"), Bytes.pack(2n) ]
    } : FA2_V.token_metadata) in

    let () = assert_with_error (token_metadata = token_m) "Views - Token metadata : This test should pass, wrong token_metadata" in
    "Passed"

// -- Views - is token unique edition --
// Success
let test_is_unique_edition =
    let contract_add, _, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let strg = Test.get_storage contract_add in

    let is_unique_edition = FA2_V.is_unique_edition(1n, strg) in

    let () = assert_with_error (is_unique_edition = false) "Views - Is unique edition : This test should pass, test is unique edition" in
    "Passed"


// -- FA2 editions version originated from Serie factory contract

// -- Is minter --

let test_serie_factory_originated_is_token_minter_view =
    let contract_t_add, _, _, minter = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let strg = Test.get_storage contract_t_add in 

    let is_minter = FA2_SERIE_STR.is_token_minter ((minter, 0n : address * FA2_I.token_id), strg) in

    let () = assert_with_error (is_minter) "Views - Is minter : This test should pass, correct minter specified" in
    "Passed"

let test_serie_factory_originated_is_token_minter_view_false =
    let contract_add, _, _, _ = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let strg = Test.get_storage contract_add in

    let not_minter = Test.nth_bootstrap_account 6 in
    let is_minter = FA2_SERIE_STR.is_token_minter ((not_minter, 0n : address * FA2_I.token_id ), strg) in

    let () = assert_with_error (is_minter <> true) "Views - Is minter : This test should pass, wrong minter specified" in
    "Passed"

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

    let () = assert_with_error (distribution = distri) "Views - Splits : This test should pass, wrong minter specified" in
    "Passed"

let test_gallery_factory_originated_commission_splits = 
    let contract_add, _, _, _, gallery = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let strg = Test.get_storage contract_add in

    let commission_distribution = FA2_GALLERY_STR.comission_splits (1n, strg) in

    let commission_distri = ({
        commission_pct = 500n;
        splits = [({
            address = gallery;
            pct = 1000n;
        } : FA2_I.split )]
    } : FA2_V.commissions) in

    let () = assert_with_error (commission_distribution = commission_distri) "Views Gallery - Commissions Splits : This test should pass " in
    "Passed"