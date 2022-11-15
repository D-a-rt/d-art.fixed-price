#include "fixed_price_interface.mligo"
// -- Admin check

let fail_if_not_admin (storage : admin_storage) : unit =
  match ((Tezos.call_view "is_admin" (Tezos.get_sender()) storage.permission_manager ): bool option) with
    None -> failwith "NOT_AN_ADMIN"
    | Some is_minter -> 
      if is_minter
      then unit
      else failwith "NOT_AN_ADMIN"

// -- Fixed price drops checks

let fail_if_wrong_drop_date (drop_date : timestamp ) : unit =
    let one_day : int = 86400 in
    let one_month : int = 2419200 in

    if drop_date < Tezos.get_now() + one_day
    then failwith "DROP_DATE_MUST_BE_AT_LEAST_IN_A_DAY"
    else if drop_date > Tezos.get_now() + one_month
    then failwith "DROP_DATE_MUST_BE_IN_MAXIMUM_ONE_MONTH"
    else unit

let fail_if_drop_date_not_met (fixed_price_drop : fixed_price_drop) : unit =
    if Tezos.get_now() < fixed_price_drop.drop_date
    then failwith "DROP_DATE_NOT_MET"
    else unit

let fail_if_wrong_commodity (commodity, storage : commodity * storage) : unit =
    match commodity with 
        |   Tez price -> (
                let () = assert_msg (price >= 100000mutez, "PRICE_SHOULD_BE_MINIMUM_0.1tez" ) in
                assert_msg ( price = Tezos.get_amount(), "PRICE_SHOULD_BE_EQUAL_TO_AMOUNT" )
            )
        |   Fa2 param -> (
                let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
                let commodity_fa2_base : fa2_base = {
                    address = param.address;
                    id = param.id;
                } in
                match Big_map.find_opt commodity_fa2_base storage.stable_coin with
                        Some mucoin -> assert_msg (param.amount >= mucoin, "PRICE_SHOULD_BE_MINIMUM_0.1" )
                    |   None -> (failwith "FA2_NOT_SUPPORTED" )
            )

let fail_if_wrong_price_specified (commodity : commodity) : unit =
    match commodity with
        |   Tez price -> assert_msg (price = Tezos.get_amount(), "WRONG_PRICE_SPECIFIED")
        |   Fa2 _ -> assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ")

    // -- Buy tokens checks

let fail_if_buyer_not_authorized (add, buyer : address * address option ) : unit =
    // Check if sale is private if yes check if sender is buyer
    // else unit
    match buyer with
        Some address -> if address = add then unit else failwith "SENDER_NOT_AUTHORIZE_TO_BUY"
        | None -> unit

