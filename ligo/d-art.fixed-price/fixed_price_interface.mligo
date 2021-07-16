type token_id = nat
type seller = address

// -- Token types

type fa2_token = 
[@layout:comb]
{
    fa2_address : address;
    token_id : token_id;
    amount : nat;
}

type fa2_token_identifier =
[@layout:comb]
{
    fa2_address : address;
    token_id : token_id;
}

type transfer_destination =
[@layout:comb]
{
  to_ : address;
  token_id : token_id;
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
}

// -- Fees

type fee_data = 
[@layout:comb]
{
    fee_address : address;
    fee_percent : nat;
}

type royalties_param =
[@layout:comb] 
{
  token_id: token_id;
  fee: tez;
}

// -- Fixed price sale types

type fixed_price_sale = 
[@layout:comb]
{
  price : tez;
  token_amount : nat;
  allowlist : (address, unit) map;
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

type authorized_drops_sellers_storage = (seller, unit) big_map

type fa2_dropped_storage = (fa2_token_identifier, unit) big_map

type drops_storage = (fa2_token_identifier * seller, fixed_price_drop) big_map

type storage =
[@layout:comb]
{
    admin: admin_storage;
    sales: (fa2_token_identifier * seller, fixed_price_sale) big_map;
    preconfigured_sales: (fa2_token_identifier * seller, fixed_price_sale) big_map;
    authorized_drops_seller: authorized_drops_sellers_storage;
    fa2_dropped: fa2_dropped_storage;
    drops: drops_storage;
    fee: fee_data;
}

type return = operation list * storage

// Entrypoints record params

// -- Fixed price sale

type sale_configuration =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: seller;
    price: tez;
    allowlist: (address, unit) map;
    authorization_signature: authorization_signature;
}

type sale_edition =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: seller;
    price: tez;
    allowlist: (address, unit) map;
}

type sale_deletion =
[@layout:comb]
{
    fa2_token_identifier: fa2_token_identifier;
    seller: seller;
}

// -- Fixed price drop

type drop_configuration =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: seller;
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
    seller: seller;
    authorization_signature: authorization_signature;
}

// -- Buy token

type buy_token = 
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: seller;
    authorization_signature: authorization_signature;
}
