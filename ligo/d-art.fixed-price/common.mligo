#include "interface.mligo"
// Helpers

// -- Assert

let assert_msg (condition, msg : bool * string ) : unit =
  if (not condition) then failwith(msg) else unit

// -- Math

let floor_div_tez (tz_qty, tz_qty_d : tez * nat) : tez =
    let result : (tez * tez) option = ediv tz_qty tz_qty_d in
    match result with
            None -> (failwith "DIVISION_BY_ZERO"  : tez)
        |   Some e -> e.0

let floor_div_amt (fa2_amt, fa2_amt_d : nat * nat) : nat =
    let result : (nat * nat) option = ediv fa2_amt fa2_amt_d in
    match result with
            None -> (failwith "DIVISION_BY_ZERO"  : nat)
        |   Some e -> e.0

let calculate_fee (percent, commodity : (nat option) * commodity) : commodity =
    match commodity with
        | Tez price -> (
            match percent with
                    None -> (Tez (0mutez))
                |   Some percentage -> (Tez (floor_div_tez (price * percentage, 1000n)))
        )

        | Fa2 token -> (
            match percent with
                    None -> (Fa2 ({ address = token.address; id = token.id; amount = 0n } : fa2_token))
                |   Some percentage -> (Fa2 ({ address = token.address; id = token.id; amount = floor_div_amt (token.amount * percentage, 1000n) } : fa2_token)) 
        )
        
let add_commodity (com_val, com_val_2 : commodity * commodity) : commodity =
    match com_val with
        |   Tez price -> (
            match com_val_2 with
                |   Tez price_2 -> (Tez (price + price_2))
                |   Fa2 _ -> (failwith "CAN_NOT_ADD_DIFFERENT_COMMODITIES" : commodity)
            )

        |   Fa2 token -> (
            match com_val_2 with
                |   Tez _ -> (failwith "CAN_NOT_ADD_DIFFERENT_COMMODITIES" : commodity)
                |   Fa2 token_2 -> if token.address = token_2.address && token.id = token_2.id then (Fa2 ({ address = token.address; id = token.id; amount = token.amount + token_2.amount } : fa2_token)) else (failwith "CAN_NOT_ADD_DIFFERENT_COMMODITIES" : commodity)
        )

let sub_commodity (com_val, com_minus : commodity * commodity) : commodity =
    match com_val with
        |   Tez price -> (
            match com_minus with
                |   Tez price_minus -> (
                    match (price - price_minus) with
                            Some p -> (Tez (p))
                        |   None -> (Tez (0mutez))
                    )
                |   Fa2 _ -> (failwith "CAN_NOT_SUBSTRACT_DIFFERENT_COMMODITIES" : commodity)
            )

        |   Fa2 token -> (
            match com_minus with
                |   Tez _ -> (failwith "CAN_NOT_SUBSTRACT_DIFFERENT_COMMODITIES" : commodity)
                |   Fa2 token_minus -> (
                        if token.address = token_minus.address && token.id = token_minus.id 
                        then (
                            if token.amount > token_minus.amount 
                            then (Fa2 ({ address = token.address; id = token.id; amount = abs(token.amount - token_minus.amount) } : fa2_token))
                            else (Fa2 ({ address = token.address; id = token.id; amount = 0n } : fa2_token))
                        ) else (failwith "CAN_NOT_SUBSTRACT_DIFFERENT_COMMODITIES" : commodity)
                    )
        )

// When concat the first list will be reversed, however in this case it should not be a problem
let rec concat_l (type a) (l, ld : a list * a list) : a list =
  match l with
    | [] -> ld
    | h::t -> concat_l (t, h::ld)

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

let transfer_token (from_address, to_address, fa2_token: address * address * fa2_token) : operation list=
   let contract = address_to_contract_transfer_entrypoint fa2_token.address in
   if fa2_token.amount > 0n then [Tezos.transaction [{ from_ = from_address; txs = [{ to_ = to_address; token_id = fa2_token.id; amount = fa2_token.amount}] }] 0mutez contract] else []

let transfer_tez (price, address : tez * address) : operation list =
    let contract = resolve_contract address in
    if price > 0mutez then [Tezos.transaction () price contract] else []

let handle_commodity_splits (buyer, split_fee, splits, operation_list : address * commodity * split list * operation list) : (operation list) * commodity =
    let handle_splits : (((operation list) * commodity) * split) -> (operation list) * commodity =
        fun ((operations, cm), split : ((operation list) * commodity) * split) ->
            let fee : commodity = calculate_fee (Some (split.pct), split_fee) in
            match fee with
                |   Tez price -> (
                        if price > 0mutez 
                        then concat_l(transfer_tez (price, split.address), operations), add_commodity((Tez (price)), cm)
                        else operations, cm
                    )
                |   Fa2 token -> (
                        if token.amount > 0n 
                        then concat_l(transfer_token (buyer, split.address, token), operations), add_commodity((Fa2 (token)), cm)
                        else operations, cm
                    )
    in
    match split_fee with
        |   Tez _ -> List.fold handle_splits splits (operation_list, (Tez (0mutez)))
        |   Fa2 token -> List.fold handle_splits splits (operation_list, (Fa2 ({address = token.address; id = token.id; amount = 0n})))
    
let handle_royalties (buyer, token, commodity : address * fa2_base * commodity) : (operation list) * commodity =
    match ((Tezos.call_view "royalty_splits" token.id token.address ): royalties option) with
        None -> ([]: operation list), (match commodity with Tez _ -> (Tez (0mutez)) | Fa2 token-> (Fa2 ({address = token.address; id = token.id; amount = 0n})))
        |   Some royalties_param ->
                let royalties_fee : commodity = calculate_fee ( Some (royalties_param.royalty), commodity) in
                handle_commodity_splits (buyer, royalties_fee, royalties_param.splits, ([] : operation list))

let handle_commissions (buyer, token, commodity , operation_list : address * fa2_base * commodity * (operation list)) : (operation list) * commodity =
    match ((Tezos.call_view "commission_splits" token.id token.address ): commissions option) with
            None -> operation_list, (match commodity with Tez _ -> (Tez (0mutez)) | Fa2 token-> (Fa2 ({address = token.address; id = token.id; amount = 0n})))
            |   Some param ->
                let commissions_fee : commodity = calculate_fee ( Some (param.commission_pct), commodity) in
                handle_commodity_splits (buyer, commissions_fee, param.splits, operation_list)

let commodity_transfer (commodity, from_address, to_address : commodity * address * address) : operation list =
    match commodity with
        |   Tez price -> transfer_tez (price, to_address)
        |   Fa2 token -> transfer_token (from_address, to_address, token)

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
let get_admin_fee (referrer, fa2_token, commodity, str : (address option) * fa2_base * commodity * storage) : address * commodity =
    match referrer with
        | Some _ -> (
                if Big_map.mem fa2_token str.fa2_sold
                then (
                    if str.admin.referral_activated
                    then (
                        if str.fee_secondary.percent >= 10n
                        then str.fee_secondary.address, calculate_fee (Some (abs(str.fee_secondary.percent - 10n)), commodity)
                        else str.fee_secondary.address, calculate_fee (Some (str.fee_secondary.percent), commodity)
                    )
                    else str.fee_secondary.address, calculate_fee (Some (str.fee_secondary.percent), commodity)
                )
                else (
                    if str.admin.referral_activated
                    then (
                        if str.fee_primary.percent >= 10n
                        then str.fee_primary.address, calculate_fee (Some (abs(str.fee_primary.percent - 10n)), commodity)
                        else str.fee_primary.address, calculate_fee (Some (str.fee_primary.percent), commodity)
                    )
                    else str.fee_primary.address, calculate_fee (Some (str.fee_primary.percent), commodity)
                )
            )
        | None -> (
            if Big_map.mem fa2_token str.fa2_sold
            then str.fee_secondary.address, calculate_fee (Some (str.fee_secondary.percent), commodity)    
            else str.fee_primary.address, calculate_fee (Some (str.fee_primary.percent), commodity)
        )

// -- Any kind of sale
let perform_sale_operation (fa2_token, seller, receiver, buyer, referrer, commodity, storage : fa2_base * address * address * address * (address option) * commodity * storage) : operation list =

    // Fees
    let admin_fee : address * commodity = get_admin_fee (referrer, fa2_token, commodity, storage) in
    
    let (royalties_transfer, royalties_fee) : (operation list) * commodity = handle_royalties (buyer, fa2_token, commodity) in
    let (commission_royalties_transfer, commission_fee) : (operation list) * commodity = if Big_map.mem fa2_token storage.fa2_sold then royalties_transfer, (match commodity with Tez _ -> (Tez (0mutez)) | Fa2 token-> (Fa2 ({address = token.address; id = token.id; amount = 0n}))) else handle_commissions (buyer, fa2_token, commodity, royalties_transfer) in
    
    // Transfer
    let admin_fee_transfer : operation list = commodity_transfer (admin_fee.1, buyer, admin_fee.0) in
    let receiver_transfer : operation list = transfer_token (seller, receiver, ({ address = fa2_token.address; id = fa2_token.id; amount = 1n } : fa2_token)) in

    match referrer with
        Some ref_add -> (
            if storage.admin.referral_activated 
            then (
                let referrer_fee = calculate_fee (Some (10n) , commodity) in
                let referrer_transfer : operation list = commodity_transfer (referrer_fee, buyer, ref_add) in
                
                let seller_commodity_amount : commodity = sub_commodity(commodity, add_commodity(add_commodity(add_commodity(admin_fee.1, royalties_fee), commission_fee), referrer_fee) ) in
                let seller_transfer : operation list = commodity_transfer (seller_commodity_amount, buyer, seller) in
                
                concat_l (receiver_transfer, concat_l (seller_transfer ,concat_l (commission_royalties_transfer, concat_l (admin_fee_transfer, referrer_transfer))))
            )
            else (
                let seller_commodity_amount : commodity = sub_commodity(commodity, add_commodity(add_commodity(admin_fee.1, royalties_fee), commission_fee) ) in
                let seller_transfer : operation list = commodity_transfer (seller_commodity_amount, buyer, seller) in
                
                concat_l (receiver_transfer, concat_l (seller_transfer ,concat_l (commission_royalties_transfer, admin_fee_transfer)))
            )
        )
        | None -> (
            let seller_commodity_amount : commodity = sub_commodity(commodity, add_commodity(add_commodity(admin_fee.1, royalties_fee), commission_fee) ) in
            let seller_transfer : operation list = commodity_transfer (seller_commodity_amount, buyer, seller) in
              
            concat_l (receiver_transfer, concat_l (seller_transfer ,concat_l (commission_royalties_transfer, admin_fee_transfer)))
        )
