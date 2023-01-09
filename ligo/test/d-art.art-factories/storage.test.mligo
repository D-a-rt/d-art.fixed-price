#import "../../d-art.art-factories/serie_factory.mligo" "S_F"
#import "../../d-art.art-factories/space_factory.mligo" "G_F"
#import "../d-art.permission-manager/storage.test.mligo" "P_M" 

let get_serie_factory_contract () =
    let () = Test.reset_state 8n ([]: tez list) in
    
    let minter = Test.nth_bootstrap_account 2 in
    let _, contract_add = P_M. get_permission_manager_contract (Some(minter), false) in
    
    let str : S_F.storage = {
        permission_manager = contract_add;
        series = (Big_map.empty : (nat, S_F.serie) big_map);
        metadata = (Big_map.empty : (string, bytes) big_map);
        next_serie_id = 0n;
    } in

    let taddr, _, _ = Test.originate S_F.serie_factory_main str 0tez in
    taddr, minter


let get_space_factory_contract () =
    let () = Test.reset_state 8n ([]: tez list) in
    
    let minter = Test.nth_bootstrap_account 2 in
    let _, contract_add = P_M. get_permission_manager_contract (Some(minter), false) in
    
    let str : G_F.storage = {
        permission_manager = contract_add;
        spaces = (Big_map.empty : (G_F.admin, address) big_map);
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let taddr, _, _ = Test.originate G_F.space_factory_main str 0tez in
    taddr, minter
