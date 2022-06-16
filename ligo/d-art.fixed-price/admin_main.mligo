#include "fixed_price_interface.mligo"
#include "common.mligo"
#include "fixed_price_check.mligo"

type admin_entrypoints =
    | UpdateFee of fee_data
    | UpdatePublicKey of key
    | ContractWillUpdate of bool

let admin_main (param, storage : admin_entrypoints * storage) : (operation list) * storage =
  let () = fail_if_not_admin (storage.admin) in
  let () = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
  match param with
    UpdateFee new_fee_data ->
      let () = assert_msg (new_fee_data.percent <= 50n, "PERCENTAGE_MUST_BE_MAXIUM_50") in
      ([] : operation list), { storage with fee = new_fee_data }

    | UpdatePublicKey key ->
      ([] : operation list), { storage with admin.pb_key = key; }

    | ContractWillUpdate bool -> ([] : operation list), { storage with admin.contract_will_update = bool }
