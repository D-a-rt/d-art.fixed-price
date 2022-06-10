#import "storage.test.mligo" "FA2_STR"
#import "../../d-art.fa2-editions/views.mligo" "FA2_V"
#import "../../d-art.fa2-editions/interface.mligo" "FA2_I"

// Test on views are only meant to check the success as it's not possible to 
// catch a failwith while testing a view using the Ligo Test API (I might have missed it)

// -- Minter --

// Success
let test_minter_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let minter_address = FA2_V.minter (1n, strg) in

    let () = assert_with_error (minter_address = minter) "Views - Minter : This test should pass, wrong minter specified" in
    "Passed"

// -- Views - royalty --
// Success
let test_royalty_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let royalty = FA2_V.royalty (1n, strg) in

    let () = assert_with_error (royalty = 150n) "Views - Royalty : This test should pass, wrong royalty specified" in
    "Passed"


// -- Views - royalty splits --
// Success
let test_royalty_splits_view =
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
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
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
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
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
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
    let contract_add, _, _, minter = FA2_STR.get_initial_storage(false, false) in
    let strg = Test.get_storage contract_add in

    let token_metadata = FA2_V.token_metadata (1n, strg) in

    let token_m = ({
        token_id = 1n;
        token_info = Map.literal [("edition_number"), Bytes.pack(2n) ]
    } : FA2_V.token_metadata) in

    let () = assert_with_error (token_metadata = token_m) "Views - Token metadata : This test should pass, wrong minter specified" in
    "Passed"
