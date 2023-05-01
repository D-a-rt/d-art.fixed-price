#include "interface.mligo"
#include "common.mligo"
#include "check.mligo"

type admin_entrypoints =
    | Update_primary_fee of fee_data
    | Update_secondary_fee of fee_data
    | Update_permission_manager of address
    | Contract_will_update of bool
    | Referral_activated of bool
    | Add_stable_coin of add_stable_coin
    | Remove_stable_coin of fa2_base

let admin_main (param, storage : admin_entrypoints * storage) : (operation list) * storage =
  let () = fail_if_not_admin (storage.admin) in
  let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
  match param with
    | Update_primary_fee new_fee_data ->
        let () = assert_msg (new_fee_data.percent <= 250n, "PERCENTAGE_MUST_BE_MAXIUM_25_PERCENT") in
        let () = assert_msg (new_fee_data.percent >= 0n, "PERCENTAGE_MUST_BE_MINIMUM_0_PERCENT") in
        ([] : operation list), { storage with fee_primary = new_fee_data }

    | Update_secondary_fee new_fee_data ->
        let () = assert_msg (new_fee_data.percent <= 250n, "PERCENTAGE_MUST_BE_MAXIUM_25_PERCENT") in
        let () = assert_msg (new_fee_data.percent >= 0n, "PERCENTAGE_MUST_BE_MINIMUM_0_PERCENT") in
        ([] : operation list), { storage with fee_secondary = new_fee_data }

    | Update_permission_manager add ->
      (([] : operation list), { storage with admin.permission_manager = add; })

    | Contract_will_update bool -> ([] : operation list), { storage with admin.contract_will_update = bool }

    | Referral_activated bool -> ([] : operation list), { storage with admin.referral_activated = bool }

    | Add_stable_coin param -> 
      if Big_map.mem param.fa2_base storage.stable_coin 
      then (failwith "ALREADY_STABLE_COIN")
      else ([] : operation list), { storage with stable_coin = Big_map.add param.fa2_base param.mucoin storage.stable_coin }

    | Remove_stable_coin fa2_base ->
      ([] : operation list), { storage with stable_coin = Big_map.remove fa2_base storage.stable_coin; }