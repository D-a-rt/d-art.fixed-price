#import "../../d-art.permission-manager/permission_manager.mligo" "P_M"

let get_permission_manager_contract (new_minter : address option) =
    let () = Test.reset_state 8n ([]: tez list) in
    
    let admin_str = {
        admin = Test.nth_bootstrap_account 0;
        pending_admin = (None: address option);
    } in
    
    match new_minter with
        Some m -> (
            let str = {
                admin  = admin_str;
                minters = Big_map.literal([(m, ());]) ;
                galleries = Big_map.literal([(m, ());]) ;
                metadata = ((Big_map.empty : (string, bytes) big_map));
            } in

            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.permission-manager/views.mligo" "permission_manager_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (P_M.art_permission_manager, P_M.storage) typed_address = Test.cast_address addr in
            taddr, addr
        )
        | None ->  (
            let str = {
                admin  = admin_str;
                minters = (Big_map.empty : (address, unit) big_map);
                galleries = (Big_map.empty : (address, unit) big_map);
                metadata = ((Big_map.empty : (string, bytes) big_map));
            } in

            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/d-art.contracts/ligo/d-art.permission-manager/views.mligo" "permission_manager_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (P_M.art_permission_manager, P_M.storage) typed_address = Test.cast_address addr in
            taddr, addr
        )