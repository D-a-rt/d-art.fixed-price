# TODO

- Empty message used big map when changing the pb key done !
- Get rid of the preconfigured_sale and the logic locking token in the contract in this kind of case
- Adjust the royalties handling
- Change the naming of the variables
- add pause - when updating to a new version



# d-art.fixed-price

## Compile and deployed contract

Small introduction on how to compile and deploy the d-art.fixed-price contract. Responsible to perform `private/public` fixed price `sale/drops`

#### Introduction:

Creation of a smart contract in order to deposit and withdraw tezos from a liquidity pool.

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

$ d-art.fixed-price deploy-contract
    (Deploy the contract previously compiled in the project)

$ d-art.fixed-price -v
    (Get the current version of the project)
```

## Fixed Price Sale/Drop

The contracts titled fixed_price_sale_market.mligo and fixed_price_sale_market_tez.mligo allow NFT and Fungible Edition Set sales for a fixed price in tez. `Upcoming version for FA2`

## Storage definition

This section is responsible to list and explain the storage of the contract.


``` ocaml
type storage =
[@layout:comb]
{
    admin: admin_storage;
    sales: (fa2_token_identifier * seller, fixed_price_sale) big_map;
    for_sale: (fa2_token_identifier * seller, fixed_price_sale) big_map;
    authorized_drops_seller: authorized_drops_sellers_storage;
    fa2_dropped: fa2_dropped_storage;
    drops: drops_storage;
    fee: fee_data;
}
```

### admin

The first field is `admin` and has it's own definition:


``` ocaml
type storage =
[@layout:comb]
{
    admin: admin_storage;
    ...
}

type admin_storage = {
  admin_address : address;
  pb_key : key;
  signed_message_used : signed_message_used;
}

type signed_message_used = (authorization_signature, unit) big_map

type authorization_signature = {
  signed : signature;
  message : bytes;
}
```

The admin storage is used to protect the entrypoints. By giving a message and its signature and performing a check we ensure that the message is coming from the right client. It works in a sense like an allowlist. We created this feature in order to avoid calling the contract each time a user sign in in our platform.

``admin_address`` : Define the address of the administrator of the contract.

``pb_key`` : Public key responsible to check the authorization_signature sent in order to protect the entrypoint.

``signed_message_used`` : Big_map of all the signed message already used by users to prevent the smart kids from using used one.

``authorization_signature`` : Record holding the signed message and the message in bytes.


### sales

The second field is `sales`

``` ocaml
type storage =
[@layout:comb]
{
    ...
    sales: (fa2_token_identifier * seller, fixed_price_sale) big_map;
    ...
}

type fa2_token_identifier =
[@layout:comb]
{
    fa2_address : address;
    token_id : token_id;
}

type fixed_price_sale =
[@layout:comb]
{
  price : tez;
  token_amount : nat;
  allowlist : (address, unit) map;
}
```

The `sales` record is used to hold all the active sales in the contract. A `preconfigured_sale` is considered active after the first sale, of course if the amount bought is lower than the total supply of token.

``fa2_token_identifier * seller`` : The `key` is composed of the general information of a token and a seller (the seller in the key allow mulptile user to sell the same token and differentiate them)

``fixed_price_sale`` : The `value` is composed of all the necessary information related to the sale: price of a unit, and the amount available.

Why `allowlist` in `fixed_price_sale` ?

A sale can be public or private, which will allow the owner of the token to either open the sell to everyone or restrict the access to specific buyers.

### for_sale

``` ocaml
type storage =
[@layout:comb]
{
    ...
    for_sale: (fa2_token_identifier * seller, fixed_price_sale) big_map;
    ...
}
```

As you can see the storage of the preconfigured_sale is the same as the sale one. The difference lies in the fact that a `preconfigured_sale` can be `edited` or `deleted`.

As soon as a user buy a token the tokens are transfered in `sale` big_map where `edition` and `deletion` will be forbidden to protect the first buyer.


### preconfigured_drops_seller

``` ocaml
type storage =
[@layout:comb]
{
    ...
    authorized_drops_seller: authorized_drops_sellers_storage;
    ...
}

type authorized_drops_sellers_storage = (seller, unit) big_map
```

A `drop` is slightly different than a fied price sale.

The main differences are :

    - drop_date
    - registration_periode
    - immutable (you can not edit or delete a drop)
    - can only be configured once per set of token
    - can only be configured by the minter of the token


``authorized_drops_sellers`` : The list of minters present in our FA2 contract. Here we make sure that it can only be congifured by the minter of the token.

### fa2_dropped


``` ocaml
type storage =
[@layout:comb]
{
    ...
    fa2_dropped: fa2_dropped_storage;
    ...
}

type fa2_dropped_storage = (fa2_token_identifier, unit) big_map
```


``fa2_dropped`` : The list of token already dropped. Here we make sure that it can only be congifured once.


### drops


``` ocaml
type storage =
[@layout:comb]
{
    ...
    drops: drops_storage;
    ...
}

type drops_storage = (fa2_token_identifier * seller, fixed_price_drop) big_map

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
```

``drops_storage`` : The `Big_map` having the same key as the sales but different values.

``fixed_price_drop`` : The drops' `Big_map` values.

``price`` : The price of the tokens dropped.

``token_amount`` : The amount of token dropped.

``registration`` : The boolean is needed to know if the drop is going to be with a registration period to access the sale.

``registration_list`` : The registration is a `map` of `address` (users) that registered for the sale of the drop. The maximum amount of user is define by the amount of token.

``allowlist`` : If the map is empty the drop is public if not it will be a private drop.

Note: it is not possible to have both a registration periode and a private drop at the same time.

``drop_date`` : The time when the sale start.

``sale_duration`` : The amount of time registered buyers will have the priority on the drop sale, once this duration is passed, the drop becomes public.


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
    | SaleConfiguration of sale_configuration
    | SaleEdition of sale_edition
    | SaleDeletion of sale_deletion
    | DropConfiguration of drop_configuration
    | DropRegistration of drop_registration
    | BuyFixedPriceToken of buy_token
    | BuyDroppedToken of buy_token
```

### Admin

The `Admin` entrypoints is responsible to add/remove seller to the `authorized_drop_seller` big_map and change the `pb_key` responsible to check the message and it's signature.

The entrypoints protected are:

    - SaleConfiguration
    - DropConfiguration
    - DropRegistration
    - BuyFixedPriceToken
    - BuyDroppedToken

#### admin_entrypoints

``` ocaml
type admin_entrypoints =
    | UpdatePublicKey of key
    | AddDropSeller of seller
    | RemoveDropSeller of seller
```

##### UpdatePublicKey

Entrypoints to update public key for the signature verification.

##### AddDropSeller

Entrypoints to add new seller to the authorize one (can be used on curated platform as soon as a minter is added to an FA2 contract)

##### RmoveDropSeller

Entrypoints to remove new seller to the authorize one (can be used on curated platform as soon as a minter is removed from an FA2 contract)

### SaleConfiguration

The `SaleConfiguration` entrypoint is responsible to configure a sale.


``` ocaml
type sale_configuration =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: seller;
    price: tez;
    allowlist: (address, unit) map;
    authorization_signature: authorization_signature;
}
```
All the needed field to configure a sale. The entrypoints only contains record already defined previously.


### SaleEdition

The `SaleEdition` entrypoint is responsible to edit a sale.


``` ocaml
type sale_edition =
[@layout:comb]
{
    fa2_token: fa2_token;
    seller: seller;
    price: tez;
    allowlist: (address, unit) map;
}

```
All the needed field to edit a `preconfigured_sale`. The entrypoints only contains record already defined previously.


### SaleDeletion

The `SaleDeletion` entrypoint is responsible to delete a sale.


``` ocaml
type sale_deletion =
[@layout:comb]
{
    fa2_token_identifier: fa2_token_identifier;
    seller: seller;
}

```
All the needed field to delete a `preconfigured_sale`. The entrypoints only contains record already defined previously.

### DropConfiguration

The `DropConfiguration` entrypoint is responsible to configure a drop.

Note: A drop can not be edited or deleted, `registration` drops and private `drops` can not be set at the same time, after a `sale_duration` the sale will go public.

``` ocaml
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
```

All the needed field to configure a `drop`. The entrypoints only contains record already defined previously.

### DropRegistration

The `DropRegistration` entrypoint is responsible to register to a drop.

Note: The registration period opens as soon as a drop is configured with `registration: true`, registered buyers will be able to buy at `least one token` from the sale or `total_supply_of_token/registered_buyers` during a `sale_duration` after which the sale will become public (the first to click will then have the privilege to buy a token - of course depending on the gas specified)

``` ocaml
type drop_registration =
[@layout:comb]
{
    fa2_token_identifier: fa2_token_identifier;
    seller: seller;
    authorization_signature: authorization_signature;
}
```

All the needed field to register to a `drop`. The entrypoints only contains record already defined previously.

### BuyFixedPriceToken && BuyDroppedToken

The `BuyFixedPriceToken` entrypoint is responsible to buy a token from a `preconfigured_sale` or `sale`.

The `BuyDroppedToken`  entrypoint is responsible to buy a token from a `drop`.

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

## Errors

All the different entrypoints have requirements, we will list all the different ones here:

### Admin

If anyone except the admin try to access these entrypoints the error thrown will be:

```
Error message : "NOT_AN_ADMIN"
```

### Fixed Price Sale

Configure a token already in `sale`, `preconfigured_sale` or `drop`:

```
Error message : "TOKEN_ALREADY_IN_SALE"
Error message : "TOKEN_ALREADY_PRCONFIGURED_FOR_SALE"
Error message : "TOKEN_ALREADY_IN_DROP"
```

If the `price` or the `token_amount` of the sale is negatif or equal to 0:

```
Error message : "PRICE_NEEDS_TO_BE_GREATER_THAN_0"
Error message : AMOUNT_OF_TOKEN_NEEDS_TO_BE_GREATER_THAN_0
```

If a buyer wants to buy a none listed token:

```
Error message : "FA2_NOT_PRECONFIGURED_FOR_SALE"
```

If the allowlist set is bigger than the amount of token:

```
Error message : "ALLOWLIST_CAN_T_BE_BIGGER_THAN_AMOUNT_OF_TOKEN"
```

### Fixed Price Drop

If the drop_date specified is incorrect:

```
Error message : "DROP_DATE_MUST_BE_AT_LEAST_IN_TWO_DAYS"
Error message : DROP_DATE_MUST_BE_IN_MAXIMUM_TWO_WEEKS
```

If the duration of the sale is wrong:

```
Error message : "DURATION_OF_THE_SALE_MUST_BE_SUPERIOR_OR_EQUAL_AT_ONE_DAY"
```

If seller tries to create a registration drop and a private one at the same one

```
Error message : "YOU_CAN_NOT_CONFIGURE_A_REGISTRATION_DROP_WITH_AN_ALLOWLIST_IT_SHOULD_BE_ONE_OR_THE_OTHER"
```

If seller tries to drop a token already dropped:

```
Error message : "FA2_TOKEN_ALREADY_BEEN_DROPPED"
```

If buyer try to register to a drop where he s already registered or none existant:

```
Error message : "DROP_DOES_NOT_EXIST"
Error message : "SENDER_ALREADY_REGISTERED"
```

If the registration perio is over:

```
Error message : "REGISTRATON_IS_CLOSED_FOR_THIS_DROP"
```

If registration list is sold out:

```
Error message : "REGISTRATION_IS_SOLD_OUT"
```

If buyer try to buy before the drop date:

```
Error message : "DROP_DATE_NOT_MET"
```

If buyer is not drop seller :

```
Error message : "SENDER_IS_NOT_AUTHORZED_DROP_SELLER"
```

### Buy tokens

If buyer try to buy more token than available:

```
Error message : "TOKEN_AMOUNT_TO_HIGH"
```

If buyer not authorized to buy from a fixed price sale

```
Error message : "SENDER_NOT_AUTHORIZE_TO_BUY"
```

If buyer not authorized to buy from a fixed price drop

```
Error message : "SENDER_NOT_AUTHORIZE_TO_PARTICIPATE_TO_THE_DROP"
```

If buyer wants to buy more token than authorized (represented by amount_of_buyers_in_private_sale / token_amount):

```
Error message : "TOKEN_AMOUNT_TO_HIGH"
```
