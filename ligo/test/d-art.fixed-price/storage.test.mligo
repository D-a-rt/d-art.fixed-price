#import "../../d-art.fixed-price/fixed_price_main.mligo" "FP"

let get_fixed_price_contract (signature_saved : bool) = 
    let () = Test.reset_state 6n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let fee_account = Test.nth_bootstrap_account 2 in

    let signed_ms = if signature_saved
        then Big_map.literal([
                ("54657374206d657373616765207465746574657465": bytes), ()        
            ])
        else  (Big_map.empty : FP.signed_message_used) 
    in

    let admin_str : FP.admin_storage = {
        address = admin;
        pb_key = ("edpkttsmzdmXenJw1s5VoXfrBHdo2f3WX9J3cyYByMj2cQSqzRR9uT" : key);
        signed_message_used = signed_ms;
        contract_will_update = false;
    } in

    let empty_sales = (Big_map.empty : (FP.fa2_base * address, FP.fixed_price_sale) big_map ) in
    let drops_str = (Big_map.empty : (FP.fa2_base * address, FP.fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (FP.fa2_base, unit) big_map) in
    let empty_offers = (Big_map.empty : (FP.fa2_base * address, tez) big_map) in
    
    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = drops_str;
        fa2_sold = empty_dropped;
        fa2_dropped = empty_dropped;
        offers = empty_offers;
        fee_primary = {
            address = fee_account;
            percent = 35n;
        };
        fee_secondary = {
            address = fee_account;
            percent = 100n;
        };
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
    let taddr : (FP.fixed_price_entrypoints, FP.storage) typed_address = Test.cast_address addr in
    let fa2_edition_contract = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
    addr, taddr, fa2_edition_contract
