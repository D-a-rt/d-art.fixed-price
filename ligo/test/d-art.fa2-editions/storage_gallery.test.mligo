
// -- FA2 editions version originated from Gallery factory contract

#include "../../d-art.fa2-editions/compile_fa2_editions_gallery.mligo"

let get_fa2_editions_gallery_contract () : ( ((editions_entrypoints, editions_storage) typed_address) * address * address * address * address ) = 
    let () = Test.reset_state 10n ([]: tez list) in
 
    let minter = Test.nth_bootstrap_account 7 in
    let gallery = Test.nth_bootstrap_account 8 in

    let admin_str : admin_storage = {
        admins = Map.literal([(gallery, ());]);
        minters = Big_map.literal([
            (minter, ());
        ]);
        pending_minters = (Big_map.empty : (address, unit) big_map);
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


let get_fa2_editions_gallery_contract_fixed_price (fixed_price_contract : address) : ( ((editions_entrypoints, editions_storage) typed_address) * address * address * address ) = 
    let token_minter = Test.nth_bootstrap_account 3 in
    let token_split = Test.nth_bootstrap_account 5 in
    let token_buyer = Test.nth_bootstrap_account 1 in

    let gallery = Test.nth_bootstrap_account 8 in

    let admin_str : admin_storage = {
        admins = Map.literal([(gallery, ());]);
        minters = Big_map.literal([
            (token_minter, ());
        ]);
        pending_minters = (Big_map.empty : (address, unit) big_map);
    } in
    
    let asset_strg : nft_token_storage = {
        ledger = Big_map.literal([
            (0n), (token_minter)        
        ]);
        operators = Big_map.literal([
            ((token_minter, (fixed_price_contract, 0n)), ())  ;      
            ((token_buyer, (fixed_price_contract, 0n)), ())  ;      
        ]);
        token_metadata = (Big_map.empty : (token_id, token_metadata) big_map);
    } in

    let edition_meta : edition_metadata = ({
            minter = token_minter;
            edition_info = (Map.empty : (string, bytes) map);
            total_edition_number = 2n;
            royalty = 150n;
            license = {
                upgradeable = False;
                hash = ("" : bytes);
            };
            splits = [({
                address = token_minter;
                pct = 500n;
            } : split );
            ({
                address = token_split;
                pct = 500n;
            } : split )];
            gallery_commission = 500n;
            gallery_commission_splits = [({
                address = gallery;
                pct = 1000n;
            } : split )];
        } : edition_metadata ) in

    let edition_meta_strg : editions_metadata = Big_map.literal([
        (0n), (edition_meta);
    ]) in

    // Contract storage
    let str = {
        next_edition_id = 1n;
        max_editions_per_run = 50n ;
        editions_metadata = edition_meta_strg;
        mint_proposals = (Big_map.empty : (nat, edition_metadata) big_map);
        assets = asset_strg;
        admin = admin_str;
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let michelson_str = Test.compile_value str in
    let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.fa2-editions/compile_fa2_editions_gallery.mligo" "editions_main" ([] : string list) michelson_str 0tez in
    let t_addr : (editions_entrypoints, editions_storage) typed_address = Test.cast_address addr in

    t_addr, gallery, addr, token_minter
