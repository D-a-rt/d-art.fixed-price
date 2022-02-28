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
  txs : transfer_destination list;
}


// -- Admin types

type authorization_signature = {
  signed : signature;
  message : bytes;
}

type signed_message_used = (authorization_signature, unit) big_map

type admin_storage =
[@layout:comb]
{
  address : address;
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
  allowlist : (address, nat) map;
}

// Entrypoints record params

// -- Fixed price sale

type sale_info =
[@layout:comb]
{
  allowlist: (address, nat) map;
  price: tez;
  seller: address;
  authorization_signature: authorization_signature;
  fa2_token: fa2_token;
}

type sale_deletion =
[@layout:comb]
{
  fa2_base: fa2_base;
  seller: address;
}

// -- Fixed price drop

type registration =
[@layout:comb]
{
  utility_token: fa2_base option;
  priority_duration: nat;
  active: bool;
}

type drop_configuration =
[@layout:comb]
{
  registration: registration;
  authorization_signature: authorization_signature;
  fa2_token: fa2_token;
  price: tez;
  drop_date: timestamp;
  seller: address;
}

type fixed_price_drop =
[@layout:comb]
{
  price: tez;
  token_amount: nat;
  registration: registration;
  registered_buyers: (address, unit) map;
  drop_owners: (address, unit) map;
  drop_date: timestamp;
}

type drop_registration =
[@layout:comb]
{
  fa2_base: fa2_base;
  seller: address;
  authorization_signature: authorization_signature;
}

type drops_storage = (fa2_base * address, fixed_price_drop) big_map

// Contract storage

type storage =
[@layout:comb]
{
  admin: admin_storage;
  for_sale: (fa2_base * address, fixed_price_sale) big_map;
  authorized_drops_seller: (address, unit) big_map;
  drops: drops_storage;
  fa2_dropped: (fa2_base, unit) big_map;
  fee: fee_data;
}

type return = operation list * storage

// -- Buy token

type buy_token =
[@layout:comb]
{
  fa2_token: fa2_token;
  seller: address;
  authorization_signature: authorization_signature;
}
