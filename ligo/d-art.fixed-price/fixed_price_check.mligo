
// -- Math

let ceil_div_nat (numerator, denominator : nat * nat) : nat =
  let ediv_result : (nat * nat) option = ediv numerator denominator in
  match ediv_result with
    | None -> (failwith "DIVISION_BY_ZERO" : nat)
    | Some result ->
      let (quotient, _reminder) = result in
      quotient

// -- Admin check

let fail_if_not_admin (storage : admin_storage) : unit =
  if Tezos.sender <> storage.address
  then failwith "NOT_AN_ADMIN"
  else unit

// -- Fixed price sales checks

let assert_wrong_allowlist (fa2_token, allowlist : fa2_token * (address, nat) map) : unit =
    let total_amount : nat =
        let calc_amount (acc, buyer: nat * (address * nat)) : nat = acc + buyer.1 in
    Map.fold calc_amount allowlist 0n in
    let () = assert_msg ( total_amount = fa2_token.amount, "Buyers amount should be equao to token amount" ) in

    match Big_map.find_opt Tezos.sender allowlist with
        None -> unit
        | Some addr -> (failwith "Seller can not be allowlisted")


// -- Fixed price drops checks

  //  let two_days : int = 172800 in
  //  let one_month : int = 2419200 in

let fail_if_wrong_drop_date (drop_date : timestamp ) : unit =
    let two_days : int = 120 in
    let one_month : int = 2419200 in

    if drop_date < Tezos.now + two_days
    then failwith "DROP_DATE_MUST_BE_AT_LEAST_IN_TWO_DAYS"
    else if drop_date > Tezos.now + one_month
    then failwith "DROP_DATE_MUST_BE_IN_MAXIMUM_ONE_MONTH"
    else unit

let fail_if_registration_period_over (drop_registration, storage : drop_registration * storage) : unit =
    match Big_map.find_opt (drop_registration.fa2_base, drop_registration.seller) storage.drops with
      None -> failwith "DROP_DOES_NOT_EXIST"
    | Some fixed_price_drop ->
        if Tezos.now > fixed_price_drop.drop_date
        then unit
        else failwith "REGISTRATON_IS_CLOSED"

let fail_if_drop_date_not_met (fixed_price_drop : fixed_price_drop) : unit =
    if Tezos.now < fixed_price_drop.drop_date
    then failwith "DROP_DATE_NOT_MET"
    else unit

let assert_wrong_registration_conf (drop_info : drop_configuration ) : unit =
    if drop_info.registration.active && drop_info.registration.priority_duration < 86400n
    then failwith "Priority duration must be at least 24h"
    else unit

// -- Buy tokens checks

let fail_if_token_amount_to_high (allowlist, buy_token : (address, nat) map * buy_token) : unit =
    if Map.size allowlist = 0n then unit
    else match (Map.find_opt Tezos.sender allowlist) with
        None -> (failwith "NOT_AUTHORIZED_BUYER" : unit)
        | Some allowed_amount -> assert_msg (allowed_amount > buy_token.fa2_token.amount, "Amount specified to high")

let fail_if_sender_not_authorized (allowlist : (address, nat) map ) : unit =
    // If it s a public sale the allowlist will be empty else we check if the sender
    // is in the allowlist
    if Map.size allowlist = 0n || ( Map.size allowlist > 0n && Map.mem Tezos.sender allowlist )
    then unit
    else failwith "SENDER_NOT_AUTHORIZE_TO_BUY"

let fail_if_sender_not_authorized_for_fixed_price_drop (fixed_price_drop, buy_token : fixed_price_drop * buy_token ) : unit =
    if fixed_price_drop.registration.active
    then
        if abs (Tezos.now - fixed_price_drop.drop_date) > fixed_price_drop.registration.priority_duration
        then unit
        else
            // Fail if not register to a drop except if drop is a day old open to public
            // Change to register priority duration to be more explicit

            match fixed_price_drop.registration.utility_token with
            | Some token ->
                let request : get_balance_param = {
                    owner = Tezos.sender;
                    token_id = token.id;
                } in
                if handle_utility_access (request, token.address) > 0n && not Map.mem Tezos.sender fixed_price_drop.drop_owners
                then assert_msg (buy_token.fa2_token.amount = 1n, "NOT_ALLOWED_TO_PURCHASE_MORE_THAN_ONE_TOKEN" )
                else failwith "SENDER_NOT_AUTHORIZE_TO_PARTICIPATE_TO_THE_DROP"
            | None ->
                if Map.mem Tezos.sender fixed_price_drop.registration_list && not Map.mem Tezos.sender fixed_price_drop.drop_owners
                then assert_msg (buy_token.fa2_token.amount = 1n, "NOT_ALLOWED_TO_PURCHASE_MORE_THAN_ONE_TOKEN" )
                else failwith "SENDER_NOT_AUTHORIZE_TO_PARTICIPATE_TO_THE_DROP"

let drop_using_utility_token (drop: fixed_price_drop) : bool =
    match drop.registration.utility_token with
        None -> false
        | Some token -> true