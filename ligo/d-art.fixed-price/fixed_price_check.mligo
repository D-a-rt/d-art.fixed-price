#include "fixed_price_interface.mligo"
// -- Admin check

let fail_if_not_admin (storage : admin_storage) : unit =
  if Tezos.get_sender() <> storage.address
  then failwith "NOT_AN_ADMIN"
  else unit

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


// -- Buy tokens checks

let fail_if_buyer_not_authorized (add, buyer : address * address option ) : unit =
    // Check if sale is private if yes check if sender is buyer
    // else unit
    match buyer with
        Some address -> if address = add then unit else failwith "SENDER_NOT_AUTHORIZE_TO_BUY"
        | None -> unit

