// Helpers

// -- Assert

let assert_msg (condition, msg : bool * string ) : unit =
  if (not condition) then failwith(msg) else unit

// -- Math

let ceil_div_tez (tz_qty, nat_qty : tez * nat) : tez =
  let ediv1 : (tez * tez) option = ediv tz_qty nat_qty in
  match ediv1 with
    | None -> (failwith "DIVISION_BY_ZERO"  : tez)
    | Some e ->
       let (quotient, remainder) = e in
       if remainder > 0mutez then (quotient + 1mutez) else quotient

let calculate_fee (percent, sale_value : (nat option) * tez) : tez =
  match percent with
    None -> 0mutez
    | Some percentage -> ceil_div_tez (sale_value *  percentage, 100n)

let sub_tez (tez_val, tez_minus : tez * tez ) : tez =
  match (tez_val - tez_minus) with
    Some tez -> tez
    | None -> 0mutez

// -- Contracts

let address_to_contract_transfer_entrypoint(add : address) : ((transfer list) contract) =
  let contract : (transfer list) contract option = Tezos.get_entrypoint_opt "%transfer" add in
  match contract with
    None -> (failwith "Invalid FA2 Address" : (transfer list) contract)
  | Some contract ->  contract

let resolve_contract (add : address) : unit contract =
  match ((Tezos.get_contract_opt add) : (unit contract) option) with
      None -> (failwith "Return address does not resolve to contract" : unit contract)
    | Some c -> c

type royalties =
[@layout:comb]
{
  address: address;
  percentage: nat;
}

let handle_royalties (token, price : fa2_base * tez) : tez * (operation list) =
  match ((Tezos.call_view "minter_royalties" token.id token.address ): royalties option) with
    None -> 0mutez, ([]: operation list)
    | Some royalties_param ->
      let royalties_fee : tez = calculate_fee ( Some (royalties_param.percentage), price) in
      let royalties_contract : unit contract = resolve_contract royalties_param.address in
      royalties_fee, [(Tezos.transaction unit royalties_fee royalties_contract)]

type get_balance_param =
[@layout:comb]
{
  owner: address;
  token_id: nat;
}

let transfer_token (transfer, fa2_address: transfer * address) : operation =
   let contract = address_to_contract_transfer_entrypoint fa2_address in
   (Tezos.transaction [transfer] 0mutez contract)

// -- Verify signature

let signed_message_used (authorization_signature, storage : authorization_signature * storage) : bool =
  Big_map.mem authorization_signature storage.admin.signed_message_used

let signed_message_not_valid (authorization_signature, storage : authorization_signature * storage) : bool =
  not Crypto.check storage.admin.pb_key authorization_signature.signed authorization_signature.message

let mark_message_as_used (authorization_signature, storage : authorization_signature * storage) : signed_message_used =
  let new_signed_message_used : signed_message_used = Big_map.add authorization_signature unit storage.admin.signed_message_used in
  new_signed_message_used

let verify_signature (authorization_signature, storage : authorization_signature * storage) : unit =
  if signed_message_used (authorization_signature, storage) || signed_message_not_valid (authorization_signature, storage)
  then failwith "UNAUTHORIZED_USER"
  else unit

// -- Fixed price sale

let get_sale (fa2_base, seller, storage : fa2_base * address * storage) : fixed_price_sale =
    // Fail if fixed price sale is not present
    match ( Big_map.find_opt (fa2_base, seller) storage.for_sale ) with
          Some fixed_price_sale -> fixed_price_sale
        | None ->  (failwith "TOKEN_IS_NOT_IN_SALE" : fixed_price_sale)

// -- Fixed price drop

let get_drop (fa2_base, seller, storage : fa2_base * address * storage) : fixed_price_drop =
    match ( Big_map.find_opt (fa2_base, seller) storage.drops ) with
          Some fixed_price_drop -> fixed_price_drop
        | None ->  (failwith "TOKEN_IS_NOT_IN_DROP" : fixed_price_drop)

// -- Any kind of sale

let perform_sale_operation (buy_token, price, storage : buy_token * tez * storage) : operation list =

  let admin_contract : unit contract = resolve_contract storage.fee.address in
  let admin_fee : tez = calculate_fee ( Some (storage.fee.percent) , price) in

  let (royalties_fee, royalties_transfer) : tez * (operation list) = handle_royalties (buy_token.fa2_token, price) in

  let seller_contract : unit contract = resolve_contract buy_token.seller in
  let seller_tez_amount : tez = sub_tez(sub_tez(price, admin_fee), royalties_fee) in

  let admin_fee_transfer : operation = Tezos.transaction unit admin_fee admin_contract in
  let seller_transfer : operation = Tezos.transaction unit seller_tez_amount seller_contract in
  let buyer_transfer : operation = transfer_token ({ from_ = buy_token.seller; txs = [{ to_ = Tezos.sender; token_id = buy_token.fa2_token.id; amount = 1n}] }, buy_token.fa2_token.address) in

  // List of all the performed operation
  (admin_fee_transfer :: buyer_transfer :: seller_transfer :: royalties_transfer )

