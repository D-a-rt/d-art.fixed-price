# d-art.contracts

#### Introduction:

This set of contracts has been developped in order to perform fixed price sale and drop on-chain.


#### Install the CLI (TypeScript):

To install all the dependencies of the project please run:

```
$ cd /d-art.contracts
$ npm install
$ npm run-script build  ( || npm run-script build:watch . )
$ npm install -g
```

The different available commands are:

Available contract title: ***fixed-price, fa2-editions***
```
$ d-art.contracts test-contract -t <contract-title>
    (Run the ligo test on the contract corresponding to the title - if no title specified run the test for the the two contracts)

$ d-art.contracts compile-contract -t <contract-name>
    (Compile the contract corresponding to the title - if no title specified compile the two contracts)

$ d-art.contracts deploy-contract -t <contract-name>
    (Deploy the contract corresponding to the title - if no title specified deploy the two contracts)

$ d-art.contracts contract-size -t <contract-name>
    (Give the size of the contracts to deploy - if not title specified give the size of each contract)

$ d-art.fixed-price gen-keypair
    (Generate public/private key pair in order to create signed message)

$ d-art.fixed-price sign-payload
    (Sign a random payload and give back message as bytes + signed message )

$ d-art.fixed-price deploy-contract
    (Deploy the contract previously compiled in the project)

$ d-art.fixed-price -v
    (Get the current version of the project)
```
---

## Contract : Fixed Price Sale/Drop

The contract is in the directory ligo/d-art.fixed-price and the corresponding test in ligo/test/d-art.fixed-price.

The purpose of this contract is to handle the sale of FA2 NFTs, the diffrent features are:

- Create classic fix price sales
- Create private fix price sales (sell to a specfic address)
- Updates fixed price sales (either price or buyer - address to sell the nft to)
- Revoke fixed price sales
- Create drops similat to a fixed price sale (Except that drop date will be specified - and the token won't be able to purchased before this drop date. A drop can be revoked only 6 hours before the drop date or 24h after it has been dropped)
- Revoke drop (Restricition specified above)
- Buy a fixed price token (Royalties automatically handled on chain)
- Buy a fixed price drop (Royalties automatically handled on chain)

Note: For the entrypoints create and buy an authorization signature is asked (message and the signed message by the private key of the owner of the contract - this protection is meant to prevent bots from accessing the contract directly and restrict the access to the users of the platform)

## Storage definition

This section is responsible to list and explain the storage of the fixed price sale contract.


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
        - using utility token (only buyers owning the utility token will be able to access the drop)
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
    | RevokeDrop of drop_info
    | RegisterToDrop of drop_info
    | ClaimUtilityToken of drop_info

    (* Buy token in any sales or drops *)
    | Buy_fixed_price_token of buy_token
    | Buy_dropped_token of buy_token
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

The `RevokeSale` entrypoint is responsible to remove a sale.


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

There are three different types of drop:

    - Classic drop: similar to a fixed price sale except that drop_date is specified and no one will be able to buy the token before this drop date
    - Utility token Registration : Buyers owning the fa2 token specified during the creation of the drop (utility token or pass) will have one token reserved after the drop_date (only during the priority period) if buyers do not buy the token by this time, sale will go public
    - Open registreation : Buyers can pre-register to a drop and have priority to buy one token during the priority duration of the drop

Note: A drop can not be edited, `registration` drops and private `drops` can not be set at the same time, after a `priority_duration` the sale will go public.

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

### RevokeDrop

The `RevokeDrop` entrypoint is responsible to remove a drop, this action is only allowed after the priority duration of the drop has been passed in order to let registered buyers buy a token.
As the sale go puiblc after this time, it can then be deleted.. (We then prevent tokens from being locked forever in the contract in case seller does not sell all the tokens)


``` ocaml
type drop_info =
[@layout:comb]
{
    fa2_base: fa2_base;
    seller: address;
    authorization_signature: authorization_signature;
}
```

All the needed field to configure a `drop`. The entrypoints only contains record already defined previously.

### ClaimUtilityToken

The `ClaimUtilityToken` entrypoint is here to prevent utility token being locked forever in the contract in case the seller doesn't revoke the drop or the drop is not sold out.

There are three ways to get utility token back for registered user:
- Drop is sold out, as soon as it is all the utility token held by the contract will be transfered directly to the previous owner
- Seller revoke the drop after a certain duration
- Or owner claim the locked contract (we in this case recommand to as well update the operators big_map in your fa2 token contract)

``` ocaml
type drop_info =
[@layout:comb]
{
    fa2_base: fa2_base;
    seller: address;
    authorization_signature: authorization_signature;
}
```

All the needed field to configure a `drop`. The entrypoints only contains record already defined previously.

### RegisterToDrop

The `RegisterToDrop` entrypoint is responsible to register to a drop, in case seller didn't choose to select a utility token drop (in which case the utility token is used as a pass during the priority duration period).

Note: The registration period opens as soon as a drop is created, registered buyers will be able to buy at `most one token` during the `priority_duration` after which the sale will become public.

``` ocaml
type drop_info =
[@layout:comb]
{
    fa2_base: fa2_base;
    seller: address;
    authorization_signature: authorization_signature;
}
```

All the needed field to register to a `drop`. The entrypoints only contains record already defined previously.

### Buy_fixed_price_token && Buy_dropped_token

The `Buy_fixed_price_token` entrypoint is responsible to buy a token from a `for_sale`.

The `Buy_dropped_token`  entrypoint is responsible to buy a token from a `drops`.

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
