# Fixed Price Sale/Drop contract

The contract is in the directory ligo/d-art.fixed-price and the corresponding test in ligo/test/d-art.fixed-price.

The purpose of this contract is to handle the sale of FA2 NFTs using tez and any stable coin following the fa2 standard (not multi-asset ~ the contract can be easily tweeked to allow multi asset versions), the different features are:

- Create classic fix price sales
- Create private fix price sales (sell to a specfic address)
- Updates fixed price sales (either price or buyer - address to sell the nft to)
- Revoke fixed price sales

- Create drops similar to a fixed price sale (Except that drop date will be specified - and the token won't be able to be purchased before this drop date. A drop can be revoked only 6 hours before the drop date or 24h after it has been dropped)
- Revoke drop (Restricition specified above)

- Create offer
- Revoke offer
- Accept offer

- Buy a fixed price token (Royalties automatically handled on chain)
- Buy a fixed price drop (Royalties automatically handled on chain)

In order to pay using a stable coin, it is necessary for the admin to add the address, the id and the decimal (mucoin) of the stable coin in the big_map.

- Add stable coin
- Remove stable coin

Note: For the entrypoints create and buy an authorization signature is asked (message and the signed message by the private key of the owner of the contract - this protection is meant to prevent bots from accessing the contract directly and restrict the access to the users of the platform, on top of it will help with the referrer system)

## Storage definition

This section is responsible to list and explain the storage of the fixed price sale contract.


``` ocaml
type mucoin = nat;

type storage =
[@layout:comb]
{
    admin: admin_storage;
    for_sale: (fa2_base * seller, fixed_price_sale) big_map;
    drops: drops_storage;
    offers: (fa2_base * address, tez) big_map;
    fa2_sold: (fa2_base, unit) big_map;
    fa2_dropped: (fa2_base, unit) big_map;
    fee_primary: fee_data;
    fee_secondary: fee_data;
    stable_coin : (fa2_base, mucoin) big_map;
    metadata : (string, bytes) big_map;
}
```

## admin

The first field is `admin` and has it's own definition:


``` ocaml
type storage =
[@layout:comb]
{
    admin: admin_storage;
    ...
}

type admin_storage = {
  permission_manager : address;
  pb_key : key;
  signed_message_used : signed_message_used;
  contract_will_update : bool;
}

type signed_message_used = (authorization_signature, unit) big_map

type authorization_signature = {
  signed : signature;
  message : bytes;
}
```


``permission_manager`` : Define the address of the permission manager contract responsible to control the admin.

``pb_key`` : Public key responsible to check the authorization_signature sent in order to protect the entrypoint.

``signed_message_used`` : Big_map of all the signed messages already used by users to prevent the smart kids from using used one.

``contract_will_update`` : Boolean that will block access to the creates entrypoints. The idea behind it is to leave the ability to empty contract storage and slowly move sales to a new version of the contract.

``authorization_signature`` : Record holding the signed message and the message in bytes.


## for_sale

The second field is `for_sale`

``` ocaml
type storage =
[@layout:comb]
{
    ...
    for_sale: (fa2_base * address, fixed_price_sale) big_map;
    ...
}

type fa2_base =
[@layout:comb]
{
  id : nat;
  address : address;
}

type fixed_price_sale =
[@layout:comb]
{
  commodity : commodity;
  buyer : address option;
}
```

The `for_sale` record is used to hold all the active sales in the contract.

``fa2_base * address`` : The `key` is composed of the general information of a token and a seller address.

``fixed_price_sale`` : The `value` is composed of all the necessary information related to the sale: commodity and an optional address in order to list to a specific address.

Why `buyer` in `fixed_price_sale` ?

A sale can be public or private, which will allow the owner of the token to either open the sell to everyone or restrict the access to a specific buyer.

## fa2_sold


``` ocaml
type storage =
[@layout:comb]
{
    ...
    fa2_sold: fa2_sold_storage;
    ...
}

type fa2_sold_storage = (fa2_base, unit) big_map
```

``fa2_sold`` : The list of token already dropped. Here we make sure that it can only be dropped once.


## drops


``` ocaml
type storage =
[@layout:comb]
{
    ...
    drops: drops_storage;
    ...
}

type drops_storage = (fa2_base * address, fixed_price_drop) big_map

type fixed_price_drop =
[@layout:comb]
{
  commodity: commodity;
  drop_date: timestamp;
}

```

``drops_storage`` : The `Big_map` having the same key as the sales but different values.

``fixed_price_drop`` : The drops' `Big_map` values.

``commodity`` : The commodity in which the seller want to sell the token.

``drop_date`` : The time when the sale start. Note


## offers


``` ocaml
type storage =
[@layout:comb]
{
    ...
    offers: (fa2_base * address, tez) big_map;
    ...
}


```


## Fee

``` ocaml
type storage =
[@layout:comb]
{
    ...
    fee: fee_data;
}

type fee_data =
[@layout:comb]
{
    address : address;
    percent : nat;
}
```

`fee`: percentage that the `address` will get on every sale.


## Entrypoints

The different entrypoints of the contract are define by:

``` ocaml
type fix_price_entrypoints =
    | Admin of admin_entrypoints

    (* Fixed price sales entrypoints *)
    | Create_sales of sale_configuration
    | Update_sales of sale_edition
    | Revoke_sales of sale_deletion

    (* Offers entrypoint *)
    | Create_offer of offer_conf
    | Revoke_offer of offer_conf
    | Accept_offer of accept_off

    (* Drops entrypoint *)
    | Create_drops of drop_configuration
    | Revoke_drops of drop_info

    (* Buy token in any sales or drops *)
    | Buy_fixed_price_token of buy_token
    | Buy_dropped_token of buy_token
```

### Admin

The `Admin` entrypoints are responsible for updating fees and the `pb_key` responsible to check the message and it's signature, and prevent new seller to create new sale in case the contract will update.

#### admin_entrypoints

``` ocaml
type admin_entrypoints =
    | Update_primary_fee of fee_data
    | UpdateSecondaryfee of fee_data
    | Update_public_key of key
    | Contract_will_update of bool
    | Add_stable_coin of add_stable_coin
    | Remove_stable_coin of fa2_base
```


##### Update_primary_fee & Update_secondary_fee

Entrypoints in order to update the address and the percentage of the fee for transactions.

##### Update_public_key

Entrypoints to update public key for the signature verification.

##### Contract_will_update

Entrypoint responsible to block access to any seller for the entrypoints `Create_sales` and `Create_drops` in order to empty this contract and update the a newer version (in case a new one or new logic is implemented)

##### Add & Remove stable coin

These two entrypoints are only accessible by the admin and responsible to manage which stable coin will be accepted in the ecosystem.


### Create_sales

The `Create_sales` entrypoint is responsible to create sales (note it's possible to list multiple tokens at the time).

``` ocaml

type commodity =
  | Tez of tez
  | Fa2 of fa2_token

type sale_configuration =
[@layout:comb]
{
  sale_infos : sale_info list;
  authorization_signature: authorization_signature;
}

type sale_info =
[@layout:comb]
{
  buyer : address option;
  commodity: commodity;
  fa2_token: fa2_base;
}

```

All the needed field to create sales. The entrypoints only contains record already defined previously.

### Update_sales

The `Update_sales` entrypoint is responsible to edit sales (It's as well possible to update the sale of multiple tokens at the time).

`Update_sales` take the same parameters as `Create_sales` entrypoint


### Revoke_sales

The `Revoke_sales` entrypoint is responsible to remove a sale.


``` ocaml
type revoke_sales_param =
[@layout:comb]
{
  fa2_tokens: fa2_base list;
}

```
All the needed field to revoke sales. (It's as well possible to update the sale of multiple tokens at the time).

### Create_drops

The `Create_drops` entrypoint is responsible to configure drops.

Similar to a fixed price sale except that `drop_date` is specified and no one will be able to buy the token before this `drop_date`

Note: A drop can only be edited 6 hours before the drop date or 24hours after the token has been dropped.

``` ocaml

type drop_configuration =
[@layout:comb]
{
  authorization_signature: authorization_signature;
  drop_infos: drop_info list; 
}

type drop_info =
[@layout:comb]
{
  fa2_token: fa2_base;
  commodity: commodity;
  drop_date: timestamp;
}

```

All the needed field to configure a `drop`.

### Revoke_drops

The `RevokeDrop` entrypoint is responsible to remove a drop, this action can be performed latest 6 hours before the drop or 24h after the drop date. 


``` ocaml

type revoke_drops_param =
[@layout:comb]
{
  fa2_tokens: fa2_base list;
}

```

All the needed field to configure a `drop`. The entrypoints only contains record already defined previously.


### Buy_fixed_price_token && Buy_dropped_token

The `Buy_fixed_price_token` entrypoint is responsible to buy a token from a `for_sale`.

The `Buy_dropped_token`  entrypoint is responsible to buy a token from a `drops`.

``` ocaml
type buy_token =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: seller;
    buyer: address;
    authorization_signature: authorization_signature;
}
```

This two endpoints are using the same record.
