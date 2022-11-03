
// -- FA2 editions version originated from Gallery factory contract

#include "../../d-art.fa2-editions/compile_fa2_editions_gallery.mligo"

let get_fa2_editions_gallery_contract () : ( ((editions_entrypoints, editions_storage) typed_address) * address * address * address * address ) = 
    let () = Test.reset_state 10n ([]: tez list) in
 
    let minter = Test.nth_bootstrap_account 7 in
    let gallery = Test.nth_bootstrap_account 8 in

    let admin_str : admin_storage = {
        admin = gallery;
        minters = Big_map.literal([
            (minter, ());
        ]);
    } in

    // Assets storage
    let owner1 = Test.nth_bootstrap_account 1 in
    let owner2 = Test.nth_bootstrap_account 2 in
    let owner3 = Test.nth_bootstrap_account 3 in
    
    let operator1 = Test.nth_bootstrap_account 4 in
    
    let ledger = (Big_map.empty : (nat, address) big_map) in

    let operators = Big_map.literal([
        ((owner1, (operator1, 1n)), ());
        ((owner2, (operator1, 2n)), ());
        ((owner3, (operator1, 3n)), ());
        ((owner1, (operator1, 4n)), ());
    ]) in
    
    let asset_str = {
        ledger = ledger;
        operators = operators;
        token_metadata = (Big_map.empty : (token_id, token_metadata) big_map);
    } in

    let editions_meta: editions_metadata = (Big_map.empty : (nat, edition_metadata) big_map) in

    // Contract storage
    let str = {
        next_edition_id = 0n;
        max_editions_per_run = 50n ;
        editions_metadata = editions_meta;
        mint_proposals = (Big_map.empty : (nat, edition_metadata) big_map);
        assets = asset_str;
        admin = admin_str;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate editions_main str 0tez in
    taddr, gallery, owner1, minter, gallery
