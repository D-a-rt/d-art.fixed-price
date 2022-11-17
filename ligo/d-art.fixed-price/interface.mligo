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

type mucoin = nat

type authorization_signature = {
  signed : signature;
  message : bytes;
}

type signed_message_used = (bytes, unit) big_map

type add_stable_coin = 
{
  fa2_base : fa2_base;
  mucoin : mucoin;
}

type admin_storage =
{
  permission_manager : address;
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

// -- Fixed  price sale types

type commodity =
  | Tez of tez
  | Fa2 of fa2_token


type fixed_price_sale =
[@layout:comb]
{
  commodity : commodity;
  buyer : address option;
}

// Entrypoints record params

// -- Offer

type offer_conf =
[@layout:comb]
{
  fa2_token: fa2_base;
  commodity : commodity;
}

type accept_offer = 
[@layout:comb]
{
  fa2_token: fa2_base;
  buyer: address;
}

// -- Fixed price sale

type sale_info =
[@layout:comb]
{
  buyer : address option;
  commodity: commodity;
  fa2_token: fa2_base;
}

type sale_configuration =
[@layout:comb]
{
  sale_infos : sale_info list;
  authorization_signature: authorization_signature;
}

type buy_token =
[@layout:comb]
{
  fa2_token: fa2_base;
  seller: address;
  buyer: address;
  authorization_signature: authorization_signature;
  referrer: address option;
}


// -- Fixed price drop

type drop_info =
[@layout:comb]
{
  fa2_token: fa2_base;
  commodity: commodity;
  drop_date: timestamp;
}

type drop_configuration =
[@layout:comb]
{
  authorization_signature: authorization_signature;
  drop_infos: drop_info list; 
}

type fixed_price_drop =
[@layout:comb]
{
  commodity: commodity;
  drop_date: timestamp;
}

type drops_storage = (fa2_base * address, fixed_price_drop) big_map

type token_id = nat

type token_metadata =
[@layout:comb]
  {
    token_id: token_id;
    token_info: ((string, bytes) map);
  }
  
// Revoke
type revoke_param =
[@layout:comb]
{
  fa2_tokens: fa2_base list;
}



// Contract storage
type storage =
[@layout:comb]
{
  admin: admin_storage;
  for_sale: (fa2_base * address, fixed_price_sale) big_map;
  drops: drops_storage;
  offers: (fa2_base * address, commodity) big_map;
  fa2_sold: (fa2_base, unit) big_map;
  fa2_dropped: (fa2_base, unit) big_map;
  fee_primary: fee_data;
  fee_secondary: fee_data;
  metadata : (string, bytes) big_map;
  stable_coin : (fa2_base, mucoin) big_map;
}

type return = operation list * storage
