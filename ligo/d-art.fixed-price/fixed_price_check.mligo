
// -- Admin check

let fail_if_not_admin (storage : admin_storage) : unit =
  if Tezos.sender <> storage.admin_address
  then failwith "NOT_AN_ADMIN"
  else unit

// -- Fixed price sales checks

let fail_if_token_already_in_sale (fa2_token_identifier, seller, storage : fa2_token_identifier * seller * storage) : unit =
    if Big_map.mem (fa2_token_identifier, seller) storage.sales
    then failwith "TOKEN_ALREADY_IN_SALE"
    else if Big_map.mem (fa2_token_identifier, seller) storage.preconfigured_sales
    then failwith "TOKEN_ALREADY_PRCONFIGURED_FOR_SALE"
    else if Big_map.mem (fa2_token_identifier, seller) storage.drops
    then failwith "TOKEN_ALREADY_IN_DROP"
    else unit

let fail_if_token_sale_configuration_wrong (fa2_token, price : fa2_token * tez) : unit =
    if price <= 0mutez
    then failwith "PRICE_NEEDS_TO_BE_GREATER_THAN_0"
    else if fa2_token.amount <= 0n
    then failwith "AMOUNT_OF_TOKEN_NEEDS_TO_BE_GREATER_THAN_0"
    else unit

let fail_if_token_sale_not_configured (fa2_token_identifier, storage : fa2_token_identifier * storage) : unit =
    if Big_map.mem (fa2_token_identifier, Tezos.sender) storage.preconfigured_sales
    then unit
    else failwith "FA2_NOT_PRECONFIGURED_FOR_SALE"

let fail_if_allowlist_to_big (fa2_token, allowlist : fa2_token * (address, unit) map) : unit =
    if Map.size allowlist > fa2_token.amount 
    then failwith "ALLOWLIST_CAN_T_BE_BIGGER_THAN_AMOUNT_OF_TOKEN"
    else unit

// -- Fixed price drops checks

let fail_if_wrong_drop_date (drop_date : timestamp ) : unit =
    let two_days : int = 172800 in
    let two_weeks : int = 1209600 in

    if drop_date < Tezos.now + two_days
    then failwith "DROP_DATE_MUST_BE_AT_LEAST_IN_TWO_DAYS"
    else if drop_date > Tezos.now + two_weeks
    then failwith "DROP_DATE_MUST_BE_IN_MAXIMUM_TWO_WEEKS"
    else unit

let fail_if_wrong_sale_duration (sale_duration : nat ) : unit = 
    if sale_duration <= 86400n
    then failwith "DURATION_OF_THE_SALE_MUST_BE_SUPERIOR_OR_EQUAL_AT_ONE_DAY"
    else unit

let fail_if_allowlist_and_registration_not_configured_properly ( allowlist, registration : (address, unit) map * bool) : unit =
    if registration && Map.size allowlist > 0n
    then failwith "YOU_CAN_NOT_CONFIGURE_A_REGISTRATION_DROP_WITH_AN_ALLOWLIST_IT_SHOULD_BE_ONE_OR_THE_OTHER"
    else unit

let fail_if_token_already_been_dropped (fa2_token_identifier, storage : fa2_token_identifier * storage) : unit = 
    if Big_map.mem fa2_token_identifier storage.fa2_dropped
    then unit
    else failwith "FA2_TOKEN_ALREADY_BEEN_DROPPED"

let fail_if_drop_not_present_or_sender_already_registered_to_drop (drop_registration, storage : drop_registration * storage) : unit =
    match Big_map.find_opt (drop_registration.fa2_token_identifier, drop_registration.seller) storage.drops with
      None -> failwith "DROP_DOES_NOT_EXIST"
    | Some fixed_price_drop -> (
        match Map.find_opt Tezos.sender fixed_price_drop.registration_list with
          None -> unit
        | Some registered_address -> failwith "SENDER_ALREADY_REGISTERED" )

let fail_if_registration_period_over (drop_registration, storage : drop_registration * storage) : unit =
    match Big_map.find_opt (drop_registration.fa2_token_identifier, drop_registration.seller) storage.drops with
      None -> failwith "DROP_DOES_NOT_EXIST"
    | Some fixed_price_drop -> 
        if Tezos.now < fixed_price_drop.drop_date - 1300
        then unit
        else failwith "REGISTRATON_IS_CLOSED_FOR_THIS_DROP"

let fail_if_registration_list_sold_out (fixed_price_drop, storage : fixed_price_drop * storage) : unit =
    if fixed_price_drop.token_amount > Map.size fixed_price_drop.registration_list
    then unit
    else failwith "REGISTRATION_IS_SOLD_OUT"

let fail_if_drop_date_not_met (fixed_price_drop : fixed_price_drop) : unit =
    if Tezos.now < fixed_price_drop.drop_date
    then failwith "DROP_DATE_NOT_MET"
    else unit

let fail_if_sender_is_not_drop_seller (storage : storage) : unit =
    if Big_map.mem Tezos.sender storage.authorized_drops_seller
    then unit
    else failwith "SENDER_IS_NOT_AUTHORZED_DROP_SELLER"

// -- Buy tokens checks

let fail_if_not_enough_token_available (token_amount, buy_token : nat * buy_token) : unit =
    if token_amount < buy_token.fa2_token.amount
    then failwith "TOKEN_AMOUNT_TO_HIGH"
    else unit

let fail_if_sender_not_authorized_for_fixed_price_sale (fixed_price_sale : fixed_price_sale ) : unit =
    // If it s a public sale the allowlist will be empty else we check if the sender
    // is in the allowlist
    if Map.size fixed_price_sale.allowlist = 0n || ( Map.size fixed_price_sale.allowlist > 0n && Map.mem Tezos.sender fixed_price_sale.allowlist )
    then unit
    else failwith "SENDER_NOT_AUTHORIZE_TO_BUY"

let sender_in_registration_list (fixed_price_drop : fixed_price_drop) : bool =
    Map.mem Tezos.sender fixed_price_drop.registration_list

let sender_in_allow_list (fixed_price_drop : fixed_price_drop) : bool =
    Map.mem Tezos.sender fixed_price_drop.allowlist

let fail_if_sender_not_authorized_for_fixed_price_drop (fixed_price_drop : fixed_price_drop ) : unit =
    if fixed_price_drop.registration
    then
        // Fail if not register to a drop except if drop is a day old open to public
        if sender_in_registration_list fixed_price_drop || abs (Tezos.now - fixed_price_drop.drop_date) > fixed_price_drop.sale_duration
        then unit
        else failwith "SENDER_NOT_AUTHORIZE_TO_PARTICIPATE_TO_THE_DROP"
    else
        // Fail if not part of the private drop sale if it exist else continue
        if Map.size fixed_price_drop.allowlist = 0n || ( Map.size fixed_price_drop.allowlist > 0n && sender_in_allow_list fixed_price_drop )
        then unit
        else failwith "SENDER_NOT_AUTHORIZE_TO_PARTICIPATE_TO_THE_DROP"

