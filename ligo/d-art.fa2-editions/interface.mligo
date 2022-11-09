
type token_id = nat
type edition_id = nat

// -- Balance entrypoints

type balance_of_request =
[@layout:comb]
{
  owner : address;
  token_id : token_id;
}

type balance_of_response =
[@layout:comb]
{
  request : balance_of_request;
  balance : nat;
}

type balance_of_param =
[@layout:comb]
{
  requests : balance_of_request list;
  callback : (balance_of_response list) contract;
}

// -- Operator entrypoints

type operator_storage = ((address * (address * token_id)), unit) big_map

type operator_param =
[@layout:comb]
{
  owner : address;
  operator : address;
  token_id: token_id;
}

type update_operator =
[@layout:comb]
  | Add_operator of operator_param
  | Remove_operator of operator_param

type token_metadata =
[@layout:comb]
  {
    token_id: token_id;
    token_info: ((string, bytes) map);
  }

type transfer_destination_descriptor =
[@layout:comb]
{
  to_ : address option;
  token_id : token_id;
  amount : nat;
}

type transfer_descriptor =
[@layout:comb]
{
  from_ : address option;
  txs : transfer_destination_descriptor list
}

// -- Transfer entrypoint

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
  txs : transfer_destination list;
}

type split =
[@layout:comb]
{
  address: address;
  pct: nat;
}

type burn_param = 
[@layout:comb]
{ 
  owner: address;
  token_id: token_id;
}

// -- Edition entrypoints

#if SERIE_CONTRACT

type edition_metadata =
[@layout:comb]
{
    edition_info: (string, bytes) map;
    total_edition_number: nat;
    royalty: nat;
    splits: split list;
}

#else

#if GALLERY_CONTRACT

type edition_metadata =
[@layout:comb]
{
    minter : address;
    edition_info: (string, bytes) map;
    total_edition_number: nat;
    royalty: nat;
    splits: split list;
    gallery_commission: nat;
    gallery_commission_splits: split list;
}

type invitation_param = 
{
    accept: bool
}

#else

type edition_metadata =
[@layout:comb]
{
    minter : address;
    edition_info: (string, bytes) map;
    total_edition_number: nat;
    royalty: nat;
    splits: split list;
}

#endif
#endif

// -- Storage definition

// Admin storage

#if SERIE_CONTRACT

type admin_storage = {
    admin : address;
    minting_revoked: bool;
}

#else

#if GALLERY_CONTRACT

type admin_storage = {
    // In order for galleries to manage the artists from multiple addresses and 
    // in case they lose access to any of these addresses
    admins: (address, unit) map;
    minters: (address, unit) big_map;
    pending_minters: (address, unit) big_map;
}

#else

type admin_storage = {
    admin : address;
    paused_minting : bool;
    minters_manager : address;
}

#endif
#endif

type ledger = (token_id, address) big_map

type nft_token_storage = {
    ledger : ledger;
    operators : operator_storage;
    token_metadata: (token_id, token_metadata) big_map;
}

type editions_metadata = (nat, edition_metadata) big_map


#if GALLERY_CONTRACT

type editions_storage =
{
    next_edition_id : nat;
    max_editions_per_run : nat;
    editions_metadata : editions_metadata;
    mint_proposals : editions_metadata;
    assets : nft_token_storage;
    admin : admin_storage;
    metadata: (string, bytes) big_map;
}

#else

#if SERIE_CONTRACT

type editions_storage =
{
    next_edition_id : nat;
    max_editions_per_run : nat;
    editions_metadata : editions_metadata;
    assets : nft_token_storage;
    admin : admin_storage;
    metadata: (string, bytes) big_map;
}

#else

type editions_storage =
{
    next_token_id : nat;
    max_editions_per_run : nat;
    as_minted: (address, unit) big_map;
    editions_metadata : editions_metadata;
    assets : nft_token_storage;
    admin : admin_storage;
    metadata: (string, bytes) big_map;
}

#endif
#endif
