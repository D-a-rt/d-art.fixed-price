
# FA2 Editions contract 

The contract is in the directory ligo/d-art.fa2-editions and the corresponding test in ligo/test/d-art.fa2-editions.

The Editions variant of FA2 allows for the minting and distribution of many editions of an NFT that share the same metadata, but with unique identifiers (token_ids). The design of this contract also allows for the minting of many editions runs in O(n) (where n is the number of editions runs minted) and concurrent distribution of editions across multiple creators. 

This contract has been extended using the TQTezos Editions variant of the FA2 https://github.com/tqtezos/minter-sdk/tree/main/packages/minter-contracts/ligo/src/minter_collection/editions

### Modification brought to the contract:

- Remove pause entrypoint 

`We removed this entrypoint to prevent admin from being able to freeze transfering tokens within the contract`

- Add Pause minting entrypoint

`The addition of this feature is to be able to terminate the minting on this contract after a period of time (As it will be our original contract we would like to have a limited number of editions on it)`

- Add Update minters manager

`This is an additional feature in order to update the contract responsible to hold the permissions for who can mint or not on the fa2 contract`

- Removed Create and distribute editions (replaced with a mint)

- Added Burn token entrypoint

- Added royalties & split as well as views corresponding to it 

- Added `WILL_ORIGINATE_FROM_FACTORY` variable in the ligo code in order to change the structure of the contract in case it's originated from the serie-factory one or originated as is.

# FA2 editions - Original D a:rt serie

WILL_ORIGINATE_FROM_FACTORY is NOT defined here

## Storage definition

This section is responsible to list and explain the storage of the fa2-editions contract.


``` ocaml

type editions_storage =
{
    next_edition_id : nat;
    max_editions_per_run : nat;
    editions_metadata : editions_metadata;
    assets : nft_token_storage;
    admin : admin_storage;
    metadata: (string, bytes) big_map;
}

```

## next_edition_id

The first field is `next_edition_id`, auto increment every time an edition is created:


``` ocaml
type storage =
{
    next_edition_id : nat;
    ...
}

```

## max_edition_per_run

The second field is `max_edition_per_run` and define the max number of NFTs and edition can contain, this number cannot bu updated over time as the logic around the token_ids is set with this 

#### example:

```
  if max_edition_per_run = 250
  edition 0 -> the first token_id will be 0,
  edition 1 -> the first token_id will be 250
```

## editions_metadata


``` ocaml
type storage =
{
    ...
    editions_metadata: editions_metadata;
    ...
}


type editions_metadata = (nat, edition_metadata) big_map

type edition_metadata =
[@layout:comb]
{
    minter : address;
    edition_info: (string, bytes) map;
    total_edition_number: nat;
    royalty: nat;
    splits: split list;
}


type split =
[@layout:comb]
{
  address: address;
  pct: nat;
}

```

``editions_metadata`` : The big_map containing the list of edition metadata in the contract

``minter`` : Minter of the edition (Tezos.sender)

``edition_info`` : Same semantic as the token_info in a classic fa2

``total_edition_number`` : Number of NFts created in this edition

``royalty`` : Percentage of royalties 150 correspond to 15%

``splits`` : list of split

``split`` : address and correcponding percentage, the total number of pct should be = 1000


## assets


``` ocaml
type storage =
[@layout:comb]
{
    ...
    assets: nft_token_storage;
    ...
}

type ledger = (token_id, address) big_map

type nft_token_storage = {
    ledger : ledger;
    operators : operator_storage;
    token_metadata: (token_id, token_metadata) big_map;
}

type operator_storage = ((address * (address * token_id)), unit) big_map

```

This hasn't change from the TQTezos repo.

### admin : admin_storage;

``` ocaml
type storage =
{
    ...
    admin : admin_storage;
    ...
}

type admin_storage = {
    admin : address;
    paused_minting : bool;
    minters_manager : address;
}

```

``admin`` : The admin address

``paused_minting`` : Boolean blocking access to the minting entrypoint

``minters_manager`` : Contract holding the list of minters allowed to mint on this contract (serie-factory contract) - the concern contract should have a `is_minter` view taking as param an address.

## Entrypoints

The different entrypoints of the contract are define by:

``` ocaml
type editions_entrypoints =
    |   Admin of admin_entrypoints
    |   FA2 of fa2_entry_points
    |   Mint_editions of mint_edition_param list
    |   Burn_token of token_id

```

### Admin

The `Admin` entrypoints are responsible for pausing the contract (only the minting entrypoint) and updating the manager contract responsible to give or revoke access to minters.

#### admin_entrypoints

``` ocaml
type admin_entrypoints =
    |   Pause_minting of bool
    |   Update_minter_manager of address
```


##### Pause_minting

Entrypoints in order to pause minting for everyone.

##### Update_minter_manage

Entrypoints in order to update the contract holding the minters permission (made it updatable as this contract my be changed over time).


### FA2

The `FA2` entrypoints are all the entrypoint needed in order to be FA2 compliant

``` ocaml

type fa2_entry_points =
  | Transfer of transfer list
  | Balance_of of balance_of_param
  | Update_operators of update_operator list

```

### Mint_editions

The `Mint_editions` entrypoint is responsible to mint several editions at the time.

### Burn_token

The `Burn_token` entrypoint will remove token from the ledger big_map. and is only accessible from the owner of the token



# FA2 editions - Originated from factory

WILL_ORIGINATE_FROM_FACTORY is defined here

## Storage definition

This section is responsible to list and explain the storage of the fa2-editions-factory contract.


``` ocaml

type editions_storage =
{
    next_edition_id : nat;
    max_editions_per_run : nat;
    editions_metadata : editions_metadata;
    assets : nft_token_storage;
    admin : admin_storage;
    metadata: (string, bytes) big_map;
}

```

## next_edition_id

The first field is `next_edition_id`, auto increment every time an edition is created:


``` ocaml
type storage =
{
    next_edition_id : nat;
    ...
}

```

## max_edition_per_run

The second field is `max_edition_per_run` and define the max number of NFTs and edition can contain, this number cannot bu updated over time as the logic around the token_ids is set with this 

#### example:

```
  if max_edition_per_run = 250
  edition 0 -> the first token_id will be 0,
  edition 1 -> the first token_id will be 250
```

## editions_metadata


``` ocaml
type storage =
{
    ...
    editions_metadata: editions_metadata;
    ...
}


type editions_metadata = (nat, edition_metadata) big_map

type edition_metadata =
[@layout:comb]
{
    edition_info: (string, bytes) map;
    total_edition_number: nat;
    royalty: nat;
    splits: split list;
}


type split =
[@layout:comb]
{
  address: address;
  pct: nat;
}

```

``editions_metadata`` : The big_map containing the list of edition metadata in the contract

``minter`` : Minter of the edition (Tezos.sender)

``edition_info`` : Same semantic as the token_info in a classic fa2

``total_edition_number`` : Number of NFts created in this edition

``royalty`` : Percentage of royalties 150 correspond to 15%

``splits`` : list of split

``split`` : address and correcponding percentage, the total number of pct should be = 1000


## assets


``` ocaml
type storage =
[@layout:comb]
{
    ...
    assets: nft_token_storage;
    ...
}

type ledger = (token_id, address) big_map

type nft_token_storage = {
    ledger : ledger;
    operators : operator_storage;
    token_metadata: (token_id, token_metadata) big_map;
}

type operator_storage = ((address * (address * token_id)), unit) big_map

```

This hasn't change from the TQTezos repo.

### admin : admin_storage;

``` ocaml
type storage =
{
    ...
    admin : admin_storage;
    ...
}

type admin_storage = {
    admin : address;
    revoke_minting : bool;
}

```

``admin`` : The admin address

``revoke_minting`` : If set to true the contract will be blocked for ever and the serie will be terminated



## Entrypoints

The different entrypoints of the contract are define by:

``` ocaml
type editions_entrypoints =
    |   Admin of admin_entrypoints
    |   FA2 of fa2_entry_points
    |   Mint_editions of mint_edition_param list
    |   Burn_token of token_id

```

### Admin

The `Admin` entrypoints are responsible for revokin the contract (only the minting entrypoint).

#### admin_entrypoints

``` ocaml
type admin_entrypoints =
    |   Revoke_minting of bool
```


##### Revoke_minting

Entrypoints in order to revoke minting for the admin, this endpoint can be called by an artist that would like to close a serie in order to make it limited in the number of artworks, setting the revoke to true is not reversible.


### FA2

The `FA2` entrypoints are all the entrypoint needed in order to be FA2 compliant

``` ocaml

type fa2_entry_points =
  | Transfer of transfer list
  | Balance_of of balance_of_param
  | Update_operators of update_operator list

```

### Mint_editions

The `Mint_editions` entrypoint is responsible to mint several editions at the time and only accessible by the admin of the contract if the minting is not revoked.

### Burn_token

The `Burn_token` entrypoint will remove token from the ledger big_map. and is only accessible from the owner of the token
