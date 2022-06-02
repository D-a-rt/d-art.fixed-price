#include "fixed_price_interface.mligo"
// -- Admin check

let fail_if_not_admin (storage : admin_storage) : unit =
  if Tezos.sender <> storage.address
  then failwith "NOT_AN_ADMIN"
  else unit

// -- Fixed price drops checks

  //  let two_days : int = 172800 in
  //  let one_month : int = 2419200 in

let fail_if_wrong_drop_date (drop_date : timestamp ) : unit =
    let two_days : int = 120 in
    let one_month : int = 2419200 in

    if drop_date < Tezos.now + two_days
    then failwith "DROP_DATE_MUST_BE_AT_LEAST_IN_A_DAY"
    else if drop_date > Tezos.now + one_month
    then failwith "DROP_DATE_MUST_BE_IN_MAXIMUM_ONE_MONTH"
    else unit

let fail_if_drop_date_not_met (fixed_price_drop : fixed_price_drop) : unit =
    if Tezos.now < fixed_price_drop.drop_date
    then failwith "DROP_DATE_NOT_MET"
    else unit


// -- Buy tokens checks

let fail_if_sender_not_authorized (buyer : address option ) : unit =
    // Check if sale is private if yes check if sender is buyer
    // else unit
    match buyer with
        Some address -> if address = Tezos.sender then unit else failwith "SENDER_NOT_AUTHORIZE_TO_BUY"
        | None -> unit

