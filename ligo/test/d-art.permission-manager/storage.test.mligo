#import "../../d-art.permission-manager/permission_manager.mligo" "P_M"

let get_initial_str (new_minter : address option) =
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
                galleries = (Big_map.empty : (address, unit) big_map);
                metadata = ((Big_map.empty : (string, bytes) big_map));
            } in

            let taddr, _, _ = Test.originate P_M.permission_manager_main str 0tez in
            taddr
        )
        | None ->  (
            let str = {
                admin  = admin_str;
                minters = (Big_map.empty : (address, unit) big_map);
                galleries = (Big_map.empty : (address, unit) big_map);
                metadata = ((Big_map.empty : (string, bytes) big_map));
            } in

            let taddr, _, _ = Test.originate P_M.permission_manager_main str 0tez in
            taddr
        )