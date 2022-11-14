#include "fixed_price_interface.mligo"
#include "common.mligo"
#include "fixed_price_check.mligo"

type admin_entrypoints =
    | Update_primary_fee of fee_data
    | Update_secondary_fee of fee_data
    | Update_public_key of key
    | Update_permission_manager of address
    | Contract_will_update of bool

let admin_main (param, storage : admin_entrypoints * storage) : (operation list) * storage =
  let () = fail_if_not_admin (storage.admin) in
  let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
  match param with
    | Update_primary_fee new_fee_data ->
        let () = assert_msg (new_fee_data.percent <= 250n, "PERCENTAGE_MUST_BE_MAXIUM_25_PERCENT") in
        let () = assert_msg (new_fee_data.percent >= 10n, "PERCENTAGE_MUST_BE_MINIMUM_1_PERCENT") in
        ([] : operation list), { storage with fee_primary = new_fee_data }

    | Update_secondary_fee new_fee_data ->
        let () = assert_msg (new_fee_data.percent <= 250n, "PERCENTAGE_MUST_BE_MAXIUM_25_PERCENT") in
        let () = assert_msg (new_fee_data.percent >= 10n, "PERCENTAGE_MUST_BE_MINIMUM_1_PERCENT") in
        ([] : operation list), { storage with fee_secondary = new_fee_data }
    
    | Update_public_key key ->
      ([] : operation list), { storage with admin.pb_key = key; }

    | Update_permission_manager add ->
      (([] : operation list), { storage with admin.permission_manager = add; })

    | Contract_will_update bool -> ([] : operation list), { storage with admin.contract_will_update = bool }
