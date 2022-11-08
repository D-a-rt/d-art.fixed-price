#include "fixed_price_interface.mligo"
// Helpers

// -- Assert

let assert_msg (condition, msg : bool * string ) : unit =
  if (not condition) then failwith(msg) else unit

// -- Math

let ceil_div_tez (tz_qty, tz_qty_d : tez * nat) : tez =
  let ediv1 : (tez * tez) option = ediv tz_qty tz_qty_d in
  match ediv1 with
    | None -> (failwith "DIVISION_BY_ZERO"  : tez)
    | Some e -> e.0

let calculate_fee (percent, sale_value : (nat option) * tez) : tez =
  match percent with
    None -> 0mutez
    | Some percentage -> ceil_div_tez (sale_value * percentage, 1000n)

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


type split =
[@layout:comb]
{
  address: address;
  pct: nat;
}

type royalties =
[@layout:comb]
{
  royalty: nat;
  splits: split list;
}

type commissions =
[@layout:comb]
{
  commission_pct: nat;
  splits: split list;
}

let handle_royalties (token, price : fa2_base * tez) : tez * (operation list) =
    match ((Tezos.call_view "royalty_splits" token.id token.address ): royalties option) with
        None -> 0mutez, ([]: operation list)
        |   Some royalties_param ->
                let royalties_fee : tez = calculate_fee ( Some (royalties_param.royalty), price) in
                
                let handle_splits : (((operation list) * tez) * split) -> (operation list) * tez = 
                    fun ((operations, sp), split : ((operation list) * tez) * split) ->

                    let royalties_contract : unit contract = resolve_contract split.address in    
                    let split_fee : tez = calculate_fee (Some (split.pct), royalties_fee) in
                    if split_fee > 0mutez
                    then ((Tezos.transaction unit split_fee royalties_contract) :: operations), sp + split_fee
                    else operations, sp
                in
                let ops, fees = (List.fold handle_splits royalties_param.splits (([] : operation list), 0mutez)) in
                fees, ops

let handle_commissions (token, price , operation_list : fa2_base * tez * (operation list)) : tez * (operation list) =
    match ((Tezos.call_view "commission_splits" token.id token.address ): commissions option) with
            None -> 0mutez, operation_list
            |   Some param ->
                let commissions_fee : tez = calculate_fee ( Some (param.commission_pct), price) in
                
                let handle_splits : (((operation list) * tez) * split) -> (operation list) * tez = 
                    fun ((operations, sp), split : ((operation list) * tez) * split) ->

                    let commissions_contract : unit contract = resolve_contract split.address in    
                    let split_fee : tez = calculate_fee (Some (split.pct), commissions_fee) in
                    if split_fee > 0mutez
                    then ((Tezos.transaction unit split_fee commissions_contract) :: operations), sp + split_fee
                    else operations, sp
                in
                let ops, fees = (List.fold handle_splits param.splits (operation_list, 0mutez)) in
                fees, ops

let transfer_token (transfer, fa2_address: transfer * address) : operation =
   let contract = address_to_contract_transfer_entrypoint fa2_address in
   (Tezos.transaction [transfer] 0mutez contract)

// -- Authorize drop seller

let is_authorized_drop_seller (add, token : address * fa2_base) : bool = 
  match ((Tezos.call_view "is_token_minter" (add, token.id) token.address ): bool option) with
      None -> false
    | Some _b -> _b

// -- Verify signature

let signed_message_used (authorization_signature, storage : authorization_signature * storage) : bool =
  Big_map.mem authorization_signature.message storage.admin.signed_message_used

let signed_message_not_valid (authorization_signature, storage : authorization_signature * storage) : bool =
  not Crypto.check storage.admin.pb_key authorization_signature.signed authorization_signature.message

let mark_message_as_used (authorization_signature, storage : authorization_signature * storage) : signed_message_used =
  let new_signed_message_used : signed_message_used = Big_map.add authorization_signature.message unit storage.admin.signed_message_used in
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
        | None ->  (failwith "TOKEN_IS_NOT_DROPPED" : fixed_price_drop)

// -- Manage admin fees
let select_fee (fa2_token, price, str : fa2_base * tez * storage) : (unit contract) * tez =
  if Big_map.mem fa2_token str.fa2_sold
  then resolve_contract (str.fee_secondary.address), calculate_fee (Some (str.fee_secondary.percent), price)
  else resolve_contract (str.fee_primary.address), calculate_fee (Some (str.fee_primary.percent), price)

// -- Any kind of sale
let perform_sale_operation (fa2_token, seller, buyer, price, storage : fa2_base * address * address * tez * storage) : operation list =

    let admin_fee : (unit contract) * tez = select_fee (fa2_token, price, storage) in

    let (royalties_fee, royalties_transfer) : tez * (operation list) = handle_royalties (fa2_token, price) in
    let (commission_fee, commission_royalties_transfer) : tez * (operation list) = handle_commissions (fa2_token, price, royalties_transfer) in

    let seller_contract : unit contract = resolve_contract seller in
    let seller_tez_amount : tez = sub_tez(price, (admin_fee.1 + royalties_fee + commission_fee)) in

    let admin_fee_transfer : operation = Tezos.transaction unit admin_fee.1 admin_fee.0 in
    let seller_transfer : operation = Tezos.transaction unit seller_tez_amount seller_contract in
    let buyer_transfer : operation = transfer_token ({ from_ = seller; txs = [{ to_ = buyer; token_id = fa2_token.id; amount = 1n}] }, fa2_token.address) in

    // List of all the performed operation
    (admin_fee_transfer :: buyer_transfer :: seller_transfer :: commission_royalties_transfer )
