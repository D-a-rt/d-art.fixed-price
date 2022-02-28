# d-art.fixed-price

## Compile and deployed contract

Small introduction on how to compile and deploy the d-art.fixed-price contract. Responsible to perform `private/public` fixed price `sale/drops`

#### Introduction:

This contract has been developped in order to perform fixed price sale and drop on-chain.
It can perform drop (if users own utility token). Take care of royalties if the fa2 contract implement `minter_royalties` (definition below)

#### Install the CLI (TypeScript):

To install all the dependencies of the project please run:

```
$ cd /d-art.fixed-price
$ npm install
$ npm run-script build
$ npm install -g
```
In order to run the tests:
```
$ npm run-script test
```

The different available commands are:

```
$ d-art.fixed-price compile-contract
    (Compile the contract contained in the project)

$ d-art.fixed-price contract-size
    (Give back the contract code size )

$ d-art.fixed-price gen-keypair
    (Generate public/private key pair in order to create signed message)

$ d-art.fixed-price sign-payload
    (Sign a random payload and give back message as bytes + signed message )

$ d-art.fixed-price deploy-contract
    (Deploy the contract previously compiled in the project)

$ d-art.fixed-price -v
    (Get the current version of the project)
```

## Fixed Price Sale/Drop

The contracts titled fixed_price_sale_market.mligo and fixed_price_sale_market_tez.mligo allow NFT and Fungible Edition Set sales for a fixed price in tez.

## Storage definition

This section is responsible to list and explain the storage of the contract.


``` ocaml
type storage =
[@layout:comb]
{
    admin: admin_storage;
    for_sale: (fa2_base * seller, fixed_price_sale) big_map;
    authorized_drops_seller: (address, unit) big_map;
    drops: drops_storage;
    fa2_dropped: (fa2_base, unit) big_map;
    fee: fee_data;
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
  address : address;
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

The admin storage is used to protect the entrypoints. By giving a message and its signature and performing a check we ensure that the message is coming from the right client. It works in a sense like an allowlist. We created this feature in order to avoid calling the contract each time a user sign in in our platform.

``address`` : Define the address of the administrator of the contract.

``pb_key`` : Public key responsible to check the authorization_signature sent in order to protect the entrypoint.

``signed_message_used`` : Big_map of all the signed message already used by users to prevent the smart kids from using used one.

``contract_will_update`` : Boolean that will block access to create any drop or sale, (won't block the other entrypoint). The idea behind it is to empty contract storage and slowly move sales to a new version of the contract (if any).

``authorization_signature`` : Record holding the signed message and the message in bytes.


## for_sale

The second field is `for_sale`

``` ocaml
type storage =
[@layout:comb]
{
    ...
    for_sale: (fa2_base * seller, fixed_price_sale) big_map;
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
  price : tez;
  token_amount : nat;
  allowlist : (address, unit) map;
}
```

The `for_sale` record is used to hold all the active sales in the contract.

``fa2_base * seller`` : The `key` is composed of the general information of a token and a seller (the seller in the key allow mulptile user to sell the same token and differentiate them)

``fixed_price_sale`` : The `value` is composed of all the necessary information related to the sale: price of a unit, the amount available, and an optional allowlist in order to sell to specified address.

Why `allowlist` in `fixed_price_sale` ?

A sale can be public or private, which will allow the owner of the token to either open the sell to everyone or restrict the access to specific buyers.


## authorized_drops_seller

``` ocaml
type storage =
[@layout:comb]
{
    ...
    authorized_drops_seller: (address, unit) big_map;
    ...
}
```

A `drop` is slightly different than a fied price sale.

The main differences are :

    - drop_date
    - registration
        - with a registration period (will reserve one token for each participant that registered before the drop date)
        - using utility token (only buyers owning this token will be able to access the drop)
    - immutable (you can not edit or delete a drop)
    - can only be configured once per set of token
    - can only be configured by the minter of the token


``authorized_drops_sellers`` : The list of minters present in our FA2 contract. Here we make sure that it can only be congifured by the minter of the token.

## fa2_dropped


``` ocaml
type storage =
[@layout:comb]
{
    ...
    fa2_dropped: fa2_dropped_storage;
    ...
}

type fa2_dropped_storage = (fa2_base, unit) big_map
```


``fa2_dropped`` : The list of token already dropped. Here we make sure that it can only be dropped once.


## drops


``` ocaml
type storage =
[@layout:comb]
{
    ...
    drops: drops_storage;
    ...
}

type drops_storage = (fa2_base * seller, fixed_price_drop) big_map

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

type registration =
[@layout:comb]
{
  utility_token: fa2_base option;
  priority_duration: nat;
  active: bool;
}

```

``drops_storage`` : The `Big_map` having the same key as the sales but different values.

``fixed_price_drop`` : The drops' `Big_map` values.

``price`` : The price of the tokens dropped.

``token_amount`` : The amount of token dropped.

``registration`` :
- `active` : boolean specifying if registration is active,
- `priority_duration` : time during which the registered buyer will have the priority to buy
- `utility_token` : fa2 token that the buyer needs to own in order to have priority on the sale

``registered_buyers`` : The registration is a `map` of `address` (users) that registered for the sale of the drop. The maximum amount of user is define by the amount of token.

``allowlist`` : If the map is empty the drop is public if not it will be a private drop.

Note: it is not possible to have a registration period and a private drop at the same time.

``drop_date`` : The time when the sale start.

``priority_duration`` : The amount of time registered buyers will have the priority on the drop sale, once this duration is passed, the drop becomes public.


### Fee

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
    fee_address : address;
    fee_percent : nat;
}
```

`fee`: percentage that the `fee_address` will get on every sale.


## Entrypoints

The different entrypoints of the contract are define by:

``` ocaml
type fix_price_entrypoints =
    | Admin of admin_entrypoints

    (*Fixed price sales entrypoints *)
    | CreateSale of sale_configuration
    | UpdateSale of sale_edition
    | RevokeSale of sale_deletion

    (* Drops entrypoint *)
    | CreateDrop of drop_configuration
    | RegisterToDrop of drop_registration

    (* Buy token in any sales or drops *)
    | BuyFixedPriceToken of buy_token
    | BuyDroppedToken of buy_token
```

### Admin

The `Admin` entrypoints are responsible for add/remove seller to the `authorized_drop_seller` big_map, change the `pb_key` responsible to check the message and it's signature, and prevent new seller to create new sale in case the contract will update.

#### admin_entrypoints

``` ocaml
type admin_entrypoints =
    | UpdateFee of fee_data
    | UpdatePublicKey of key
    | AddDropSeller of address
    | RemoveDropSeller of address
    | ContractWillUpdate of bool
```


##### UpdateFee

Entrypoints in order to update the address and the percentage of the fee for transactions.

##### UpdatePublicKey

Entrypoints to update public key for the signature verification.

##### AddDropSeller

Entrypoints to add new seller to the authorize one (can be used on curated platform as soon as a minter is added to an FA2 contract)

##### RmoveDropSeller

Entrypoints to remove new seller to the authorize one (can be used on curated platform as soon as a minter is removed from an FA2 contract)

##### ContractWillUpdate

Entrypoint responsible to block access to any seller for the entrypoints `CreateSale` and `CreateDrop` in order to empty this contract and update the a newer version (in case a new one or new logic is implemented)


### CreateSale

The `CreateSale` entrypoint is responsible to create a sale.


``` ocaml
type sale_info =
[@layout:comb]
{
    allowlist: (address, unit) map;
    price: tez;
    seller: address;
    authorization_signature: authorization_signature;
    fa2_token: fa2_token;
}
```
All the needed field to configure a sale. The entrypoints only contains record already defined previously.


### UpdateSale

The `UpdateSale` entrypoint is responsible to edit a sale.


``` ocaml
type sale_info =
[@layout:comb]
{
    allowlist: (address, unit) map;
    price: tez;
    seller: address;
    authorization_signature: authorization_signature;
    fa2_token: fa2_token;
}
```
All the needed field to edit a sale. The entrypoints only contains record already defined previously.


### RevokeSale

The `RevokeSale` entrypoint is responsible to delete a sale.


``` ocaml
type sale_deletion =
[@layout:comb]
{
    fa2_base: fa2_base;
    seller: address;
}

```
All the needed field to delete a sale. The entrypoints only contains record already defined previously.

### CreateDrop

The `CreateDrop` entrypoint is responsible to configure a drop.

Note: A drop can not be edited or deleted, `registration` drops and private `drops` can not be set at the same time, after a `priority_duration` the sale will go public.

``` ocaml
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
```

All the needed field to configure a `drop`. The entrypoints only contains record already defined previously.

### RegisterToDrop

The `RegisterToDrop` entrypoint is responsible to register to a drop.

Note: The registration period opens as soon as a drop is created, registered buyers will be able to buy at `most one token` during the `priority_duration` after which the sale will become public.

``` ocaml
type drop_registration =
[@layout:comb]
{
    fa2_base: fa2_base;
    seller: address;
    authorization_signature: authorization_signature;
}
```

All the needed field to register to a `drop`. The entrypoints only contains record already defined previously.

### BuyFixedPriceToken && BuyDroppedToken

The `BuyFixedPriceToken` entrypoint is responsible to buy a token from a `for_sale`.

The `BuyDroppedToken`  entrypoint is responsible to buy a token from a `drops`.

``` ocaml
type buy_token =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: seller;
    authorization_signature: authorization_signature;
}
```

This two endpoints are using the same record.
