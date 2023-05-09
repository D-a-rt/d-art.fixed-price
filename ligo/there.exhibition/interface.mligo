type synthetic_id = nat

type fa2_base =
[@layout:comb]
{
  id : nat;
  address : address;
}

type fa2_token =
[@layout:comb]
{
  id : nat;
  address : address;
  amount: nat;
}

type commodity =
  | Tez of tez
  | Fa2 of fa2_token

type sale_info =
[@layout:comb]
{
  buyer : address option;
  commodity: commodity;
}

type split =
[@layout:comb]
{
    address: address;
    pct: nat;
}

// Admin Storage

type admin_storage = {
    admin: address;
    start_date: timestamp;
    end_date: timestamp;
    grace_period: nat; (* In seconds *)
    grace_started: timestamp option;
    commission: nat;
    commission_splits: split list;
    pending_invites: (fa2_base * minter, unit) big_map;
    pending_listings: (synthetic_id, sale_info) big_map;
}

// Storage

type storage =
[@layout:comb]
{
    admin_str: admin_storage;
    exhibition: (fa2_base * minter, synthetic_id) big_map;
    next_synthetic_id: nat;
    metadata : (string, bytes) big_map;
}