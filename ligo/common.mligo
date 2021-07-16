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

let calculate_sale_fee (percent, sale_value : nat * tez) : tez =
  (ceil_div_tez (sale_value *  percent, 100n))

// -- Contracts

let address_to_contract_transfer_entrypoint(add : address) : ((transfer list) contract) =
  let contract : (transfer list) contract option = Tezos.get_entrypoint_opt "%transfer" add in
  match contract with
    None -> (failwith "Invalid FA2 Address" : (transfer list) contract)
  | Some contract ->  contract

let minter_to_contract_ownership_entrypoint(contract_address : address) : royalties_param contract =
  let contract : royalties_param contract option = Tezos.get_entrypoint_opt "%minter_royalties" contract_address in
  match contract with
    None -> (failwith "Invalide FA2 Address" : royalties_param contract)
    | Some contract -> contract

let resolve_contract (add : address) : unit contract =
  match ((Tezos.get_contract_opt add) : (unit contract) option) with
      None -> (failwith "Return address does not resolve to contract" : unit contract)
    | Some c -> c

let transfer_token_in_contract (token, from_, to_ : fa2_token * address * address) : operation =
  let destination : transfer_destination = {
      to_ = to_;
      token_id = token.token_id;
      amount = token.amount;
   } in
   let transfer_param = [{from_ = from_; destinations = [destination]}] in
   let contract = address_to_contract_transfer_entrypoint token.fa2_address in
   (Tezos.transaction transfer_param 0mutez contract) 

// -- Verify signature

let signed_message_used (authorization_signature, storage : authorization_signature * storage) : bool =
  Big_map.mem authorization_signature storage.admin.signed_message_used

let signed_message_not_valid (authorization_signature, storage : authorization_signature * storage) : bool =
  not Crypto.check storage.admin.pb_key authorization_signature.signed authorization_signature.message

let mark_message_as_used (authorization_signature, storage : authorization_signature * storage) : storage =
  let new_signed_message_used : signed_message_used = Big_map.add authorization_signature unit storage.admin.signed_message_used in
  let new_admin_storage : admin_storage = { storage.admin  with signed_message_used = new_signed_message_used } in
  
  { storage with admin = new_admin_storage }

let verify_user (authorization_signature, storage : authorization_signature * storage) : unit =
  if signed_message_used (authorization_signature, storage) || signed_message_not_valid (authorization_signature, storage)
  then failwith "UNAUTHORIZED_USER"
  else unit

// -- Fixed price sale

let get_fixed_price_sale_in_maps (fa2_token_identifier, seller, storage : fa2_token_identifier * seller * storage) : fixed_price_sale =
    // Fail if fixed price sale is not present
    match ( Big_map.find_opt (fa2_token_identifier, seller) storage.preconfigured_sales ) with
          Some fixed_price_sale -> fixed_price_sale
        | None ->  (
            match ( Big_map.find_opt (fa2_token_identifier, seller) storage.sales ) with
                      Some fixed_price_sale -> fixed_price_sale
                    | None -> (failwith "TOKEN_IS_NOT_IN_SALE" : fixed_price_sale))

let token_in_preconfigured_sale (fa2_token_identifier, seller, storage : fa2_token_identifier * seller * storage) : bool =
    Big_map.mem (fa2_token_identifier, seller) storage.preconfigured_sales

let sender_in_registration_list (fixed_price_drop : fixed_price_drop) : bool =
    Map.mem Tezos.sender fixed_price_drop.registration_list

// -- Fixed price drop

let get_fixed_price_drop_in_map (fa2_token_identifier, seller, storage : fa2_token_identifier * seller * storage) : fixed_price_drop =
    // Fail if fixed price drop is not present
    match ( Big_map.find_opt (fa2_token_identifier, seller) storage.drops ) with
          Some fixed_price_drop -> fixed_price_drop
        | None ->  (failwith "TOKEN_IS_NOT_IN_DROP" : fixed_price_drop)

// -- Any kind of sale

let perform_sale_operation (buy_token, price, storage : buy_token * tez * storage) : operation list =
   
    // Get seller, fee and minter contract to transfer the money
    let seller_contract : unit contract = resolve_contract buy_token.seller in
    let fee_contract : unit contract = resolve_contract storage.fee.fee_address in
    let minter_contract : royalties_param contract = minter_to_contract_ownership_entrypoint buy_token.fa2_token.fa2_address in

    // Define the sale fee and minter fee
    let sale_fee : tez = calculate_sale_fee (storage.fee.fee_percent, price) in 
    let minter_fee : tez = calculate_sale_fee (abs(10), price) in
    
    // Transfer token to buyer
    let fa2_transfer : operation list = [transfer_token_in_contract (buy_token.fa2_token, buy_token.seller, Tezos.sender)] in

    // Transfer tez to seller
    let tez_transfer : operation = Tezos.transaction unit (price - sale_fee) seller_contract in

    // Transfer sale_fee to admin
    let sale_fee_transfer : operation = Tezos.transaction unit sale_fee fee_contract in

    let royalties_param : royalties_param = {
      token_id = buy_token.fa2_token.token_id;
      fee = minter_fee;
    } in 

    // Transfer royalties to minter
    let minter_royalties_transfer : operation = Tezos.transaction royalties_param minter_fee minter_contract in

    // List of all the performed operation
    (minter_royalties_transfer :: sale_fee_transfer :: tez_transfer :: fa2_transfer)
