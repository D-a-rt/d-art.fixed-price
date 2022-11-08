#import "../d-art.fa2-editions/storage.test.mligo" "FA2_STR"
#import "../d-art.fa2-editions/storage_gallery.test.mligo" "FA2_GALLERY_STR"

#include "../../d-art.fixed-price/fixed_price_main.mligo"

let get_fixed_price_contract_drop (will_update, isDropped, isInDrops, drop_date : bool * bool * bool * timestamp) = 
 let () = Test.reset_state 10n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let fee_account = Test.nth_bootstrap_account 2 in

    let admin_str : admin_storage = {
        address = admin;
        pb_key = ("edpkttsmzdmXenJw1s5VoXfrBHdo2f3WX9J3cyYByMj2cQSqzRR9uT" : key);
        signed_message_used = (Big_map.empty : signed_message_used) ;
        contract_will_update = will_update;
    } in

    let empty_sales = (Big_map.empty : (fa2_base * address, fixed_price_sale) big_map ) in
    let empty_drops = (Big_map.empty : (fa2_base * address, fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (fa2_base, unit) big_map) in
    
    let dropped : (fa2_base, unit ) big_map = Big_map.literal ([
                (({
                    id = 0n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } : fa2_base), ());
            ]) in

    let fa2_b_1 : fa2_base = {
                    id = 0n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } in
    
    let fa2_b_2 : fa2_base = {
                    id = 1n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } in

    let drops_str : drops_storage = Big_map.literal ([
        ((fa2_b_1, admin),
            ({
                price = 1000000mutez;
                drop_date = drop_date;
            })
        );
        ((fa2_b_2, admin),
            ({
                price = 1000000mutez;
                drop_date = drop_date;
            })
        );
    ]) in
    let empty_offers = (Big_map.empty : (fa2_base * address, tez) big_map) in


    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = empty_drops;
        fa2_sold = (Big_map.empty : (fa2_base, unit) big_map);
        fa2_dropped = empty_dropped;
        offers = empty_offers;
        fee_primary = {
            address = admin;
            percent = 10n;
        };
        fee_secondary = {
            address = fee_account;
            percent = 3n;
        };
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in


    if isDropped
    then (
        if isInDrops
        then (
            let str = { str with drops = drops_str; fa2_dropped = dropped } in
            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
            let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
            let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

            addr, taddr, fa2_add, t_fa2_add

        )
        else (
            let str = { str with fa2_dropped = dropped } in
            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
            let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
            let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

            addr, taddr, fa2_add, t_fa2_add

        )
    )
    else (
        if isInDrops
        then (
            let str = { str with drops = drops_str } in
            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
            let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
            let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

            addr, taddr, fa2_add, t_fa2_add

        )
        else (
            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
            let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
            let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

            addr, taddr, fa2_add, t_fa2_add
        )
    )

let get_fixed_price_contract (signature_saved : bool) = 
    let () = Test.reset_state 10n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let fee_account = Test.nth_bootstrap_account 2 in

    let signed_ms = if signature_saved
        then Big_map.literal([
                ("54657374206d657373616765207465746574657465": bytes), ()        
            ])
        else  (Big_map.empty : signed_message_used) 
    in

    let admin_str : admin_storage = {
        address = admin;
        pb_key = ("edpkttsmzdmXenJw1s5VoXfrBHdo2f3WX9J3cyYByMj2cQSqzRR9uT" : key);
        signed_message_used = signed_ms;
        contract_will_update = false;
    } in

    let empty_sales = (Big_map.empty : (fa2_base * address, fixed_price_sale) big_map ) in
    let drops_str = (Big_map.empty : (fa2_base * address, fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (fa2_base, unit) big_map) in
    let empty_offers = (Big_map.empty : (fa2_base * address, tez) big_map) in
    
    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = drops_str;
        fa2_sold = empty_dropped;
        fa2_dropped = empty_dropped;
        offers = empty_offers;
        fee_primary = {
            address = fee_account;
            percent = 100n;
        };
        fee_secondary = {
            address = fee_account;
            percent = 35n;
        };
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
    let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
    let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
    let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

    addr, taddr, fa2_add, t_fa2_add
    

let get_fixed_price_contract_gallery (signature_saved : bool ) =
    let () = Test.reset_state 10n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let fee_account = Test.nth_bootstrap_account 2 in

    let signed_ms = if signature_saved
        then Big_map.literal([
                ("54657374206d657373616765207465746574657465": bytes), ()        
            ])
        else  (Big_map.empty : signed_message_used) 
    in

    let admin_str : admin_storage = {
        address = admin;
        pb_key = ("edpkttsmzdmXenJw1s5VoXfrBHdo2f3WX9J3cyYByMj2cQSqzRR9uT" : key);
        signed_message_used = signed_ms;
        contract_will_update = false;
    } in

    let empty_sales = (Big_map.empty : (fa2_base * address, fixed_price_sale) big_map ) in
    let drops_str = (Big_map.empty : (fa2_base * address, fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (fa2_base, unit) big_map) in
    let empty_offers = (Big_map.empty : (fa2_base * address, tez) big_map) in
    
    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = drops_str;
        fa2_sold = empty_dropped;
        fa2_dropped = empty_dropped;
        offers = empty_offers;
        fee_primary = {
            address = fee_account;
            percent = 100n;
        };
        fee_secondary = {
            address = fee_account;
            percent = 35n;
        };
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fixed-price/fixed_price_main.mligo" "fixed_price_tez_main" ([] : string list) (Test.compile_value str) 0tez in
    let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in

    let t_fa2_gallery_add, gallery, fa2_gallery_add, _ = FA2_GALLERY_STR.get_fa2_editions_gallery_contract_fixed_price (addr) in
    addr, taddr, gallery, fa2_gallery_add, t_fa2_gallery_add
    