// -- Token types

type fa2_token =
[@layout:comb]
{
  id : nat;
  address : address;
  amount : nat;
}

type fa2_base =
[@layout:comb]
{
  id : nat;
  address : address;
}

type transfer_destination =
[@layout:comb]
{
  to_ : address;
  token_id : nat;
  amount : nat;
}

type transfer =
[@layout:comb]
{
  from_ : address;
  destinations : transfer_destination list;
}


// -- Admin types

type authorization_signature = {
  signed : signature;
  message : bytes;
}

type signed_message_used = (authorization_signature, unit) big_map

type admin_storage = {
  admin_address : address;
  pb_key : key;
  signed_message_used : signed_message_used;
  contract_will_update: bool;
}

// -- Fees

type fee_data =
[@layout:comb]
{
    address : address;
    percent : nat;
}

type royalties_param =
[@layout:comb]
{
  token_id: nat;
  fee: tez;
}

// -- Fixed price sale types

type allowed_buyer =
[@layout:comb]
{
  buyer: address;
  amount: nat
}

type fixed_price_sale =
[@layout:comb]
{
  price : tez;
  token_amount : nat;
  allowlist : allowed_buyer map;
}

type fixed_price_drop =
[@layout:comb]
{
    price: tez;
    token_amount: nat;
    registration: bool;
    registration_list: (address, unit) map;
    allowlist: (address, unit) map;
    drop_date: timestamp;
    sale_duration: nat;
}

type authorized_drops_sellers_storage = (address, unit) big_map

type fa2_dropped_storage = (fa2_token_identifier, unit) big_map

type drops_storage = (fa2_token_identifier * address, fixed_price_drop) big_map

type storage =
[@layout:comb]
{
  admin: admin_storage;
  for_sale: (fa2_token_identifier * address, fixed_price_sale) big_map;
  authorized_drops_seller: (address, unit) big_map;
  drops: drops_storage;
  fa2_dropped: fa2_dropped_storage;
  fee: fee_data;
}

type return = operation list * storage

// Entrypoints record params

// -- Fixed price sale

type sale_configuration =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: address;
    price: tez;
    allowlist: (address, unit) map;
}

type sale_edition =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: address;
    price: tez;
    allowlist: (address, unit) map;
}

type sale_deletion =
[@layout:comb]
{
    fa2_token_identifier: fa2_token_identifier;
    seller: address;
}

// -- Fixed price drop

type drop_configuration =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: address;
    price: tez;
    allowlist: (address, unit) map;
    drop_date: timestamp;
    sale_duration: nat;
    registration: bool;
    authorization_signature: authorization_signature;
}

type drop_registration =
[@layout:comb]
{
    fa2_token_identifier: fa2_token_identifier;
    seller: address;
    authorization_signature: authorization_signature;
}

// -- Buy token

type buy_token =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: address;
    authorization_signature: authorization_signature;
}
