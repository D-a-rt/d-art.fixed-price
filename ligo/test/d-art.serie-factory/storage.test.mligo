#import "../../d-art.serie-factory/serie_factory.mligo" "S_F"

let get_factory_contract () =
    let () = Test.reset_state 8n ([]: tez list) in
    
    let admin_str = {
        admin = Test.nth_bootstrap_account 0;
        pending_admin = (None: address option);
    } in

    let str = {
        admin = admin_str;
        origination_paused = false;
        minters = Big_map.literal([(Test.nth_bootstrap_account 2, unit);]);
        series = (Big_map.empty : (nat, S_F.serie) big_map);
        metadata = (Big_map.empty : (string, bytes) big_map);
        next_serie_id = 1n;
    } in

    let taddr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.serie-factory/views.mligo" "art_serie_factory_main" ([] : string list) (Test.compile_value str) 0tez in
    taddr, admin_str.admin