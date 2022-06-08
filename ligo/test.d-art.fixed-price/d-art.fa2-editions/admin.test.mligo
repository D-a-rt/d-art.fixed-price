#import "../../d-art.fixed-price/fixed_price_interface.mligo" "FP_I"
#import "../d-art.fixed-price/fixed_price_main.mligo" "FP_M"

// TEST FILE FOR ADMIN ENTRYPOINTS

// Create initial storage
let get_initial_storage () = 
    let admin = Test.nth_bootstrap_account 0 in
    let account : (string * key) = Test.new_account () in
    let signed_ms = (Big_map.empty : FP_I.signed_message_used) in
    
    let admin_str : FP_I.admin_storage = {
        address = admin;
        pb_key = account.1;
        signed_message_used = signed_ms;
        contract_will_update = false;
    } in

    let empty_sales = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_sale) big_map ) in
    let empty_sellers = (Big_map.empty : (address, unit) big_map ) in
    let empty_drops = (Big_map.empty : (FP_I.fa2_base * address, FP_I.fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (FP_I.fa2_base, unit) big_map) in

    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        authorized_drops_seller = empty_sellers;
        drops = empty_drops;
        fa2_dropped = empty_dropped;
        fee = {
            address = admin;
            percent = 3n;
        }
    } in

    let taddr, _, _ = Test.originate FP_M.fixed_price_tez_main str 0tez in
    taddr


// -- Pause numbered edition -- 
// Fail not admin 
// Fail no amount
// Success

// -- Pause minting --
// Fail not admin
// Fail no amount
// Success

// -- Add Minter --
// Fail not admin
// Fail already minter
// Fail no amount
// Success

// -- Remove minter --
// Fail if not admin
// Fail if not minter
// Fail no amount
// Success


// -- Add operator -- 
// Fail if not owner
// Fail no amount
// Success

// -- Remove minter --
// Fail if not owner
// Fail no amount
// Success

// -- Transfer --
// Fail if token undefined
// Fail if not operator/operator
// Fail if no balance
// Fail no amount
// Success if operator
// Success if owner

// -- Balance of --
// Fail no amount
// Check FA2 repo

// -- Mint editions --
// Fail no amount
// Fail if not minter
// Fail if to much receiver
// Fail if to many editions
// Fail if to low edition number
// Fail if royalties exceed 100 percent
// Fail if split more than 100%
// Success with nb receivers < edition number
// Success receivers = edition nubmer
// Success no receivers

// -- Burn Token --
// Fail no amount
// Fail if not owner
// Success



