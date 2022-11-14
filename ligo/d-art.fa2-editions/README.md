
# FA2 Editions contract 

The contracts are in the directory ligo/d-art.fa2-editions and the corresponding test in ligo/test/d-art.fa2-editions.

The Editions variant of FA2 allows for the minting and distribution of many editions of an NFT that share the same metadata, but with unique identifiers (token_ids). The design of these contracts also allows for the minting of many editions runs in O(n) (where n is the number of editions runs minted) and concurrent distribution of editions across multiple creators. 

This contract has been extended, using the TQTezos Editions variant of the FA2 https://github.com/tqtezos/minter-sdk/tree/main/packages/minter-contracts/ligo/src/minter_collection/editions



### This repo holds three variants of the fa2-editions contract:
```
-   Legacy D a:rt contract (where authorized minter of the system will be able to mint only one token as a one-off)
-   Serie contract (the fa2-editions version that minters will be able to originate using the serie-factory contract and be admin on)
-   Gallery contract (the variant enabling administrators to manage their own artists and perform pre-minting for them)
```


# FA2 editions - Legacy D a:rt gallery

SERIE_CONTRACT is NOT defined here

## Storage definition

This section is responsible to list and explain the storage of the legacy version of the fa2-editions contract.


``` ocaml

type editions_storage =
{
    next_edition_id : nat;
    max_editions_per_run : nat;
    as_minted: (address, unit) big_map;
    proposals: (nat, proposal_metadata) big_map;
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
  if max_edition_per_run = 50
  edition 0 -> the first token_id will be 0,
  edition 1 -> the first token_id will be 50
```

## as_minted

Big_map referencing the minter that already minted on the contract in order to prevent them to mint again.

## proposals

Big_map referencing the proposals of the artworks from the artists (The goal here is to make sure that token are well parametrized as it won't be possible to burn and remint token in case of problems, we want to make sure that the process is smooth )

## editions_metadata


``` ocaml
type storage =
{
    ...
    editions_metadata: editions_metadata;
    ...
}


type editions_metadata = (nat, edition_metadata) big_map

type license =
[@layout:comb]
{
    upgradeable : bool;
    hash : bytes;
}

type edition_metadata =
[@layout:comb]
{
    minter : address;
    edition_info: (string, bytes) map;
    total_edition_number: nat;
    license : license;
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

``minter`` : Minter of the edition (Tezos.get_sender())

``edition_info`` : Same semantic as the token_info in a classic fa2

``total_edition_number`` : Number of NFts created in this edition

``license`` : Contain the hash of the ipfs link of the license and the upgradeable boolean

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
    permission_manager : address;
}

```

``admin`` : The admin address

``paused_minting`` : Boolean blocking access to the minting entrypoint

``permission_manager`` : Contract holding the list of minters allowed to mint on this contract (permission-manager contract) - the concern contract should have a `is_minter` view taking as param an address.

## Entrypoints

The different entrypoints of the contract are define by:

``` ocaml
type editions_entrypoints =
    |   Admin of admin_entrypoints
    |   FA2 of fa2_entry_points
    |   Update_metadata of bytes
    |   Burn_token of burn_param

    |   Create_proposal of mint_edition_param
    |   Update_proposal of update_mint_edition_param
    |   Remove_proposal of proposal_param
    
    |   Mint_editions of proposal_param
    |   Upgrade_license of license_param

```

### Admin

The `Admin` entrypoints are responsible for pausing the contract (only the minting entrypoint) and updating the manager contract responsible to give or revoke access to minters.

#### admin_entrypoints

``` ocaml
type admin_entrypoints =
    |   Pause_minting of bool
    |   Update_permission_manager of address
    |   Add_admin of address
    |   Remove_admin of address
    |   Accept_proposals of proposal_param list
    |   Reject_proposals of proposal_param list
```


#### Pause_minting

Entrypoints in order to pause minting for everyone.

#### Update_minter_manage

Entrypoints in order to update the contract holding the minters permission (made it updatable as this contract my be changed over time).

#### Add & Remove admin

Entrypoints in order to add admin to the admins map

#### Accept & Reject proposals

entrypoint that will add a accepted flag to true of the proposal in order to let the minter mint the so called proposal.

### FA2

The `FA2` entrypoints are all the entrypoint needed in order to be FA2 compliant

``` ocaml

type fa2_entry_points =
  | Transfer of transfer list
  | Balance_of of balance_of_param
  | Update_operators of update_operator list

```

### Mint_editions

The `Mint_editions` entrypoint is responsible to mint an accepted proposal.

### Upgrade_license

The `Upgrade_license` entrypoint is responsible to update the license attached to the nft at anytime by the minter of the token (the person holding the copyright for it).

### Burn_token

The `Burn_token` entrypoint will remove token from the ledger big_map. and is only accessible from the owner of the token



# FA2 editions - Originated from serie factory

SERIE_CONTRACT is defined here

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
  if max_edition_per_run = 50
  edition 0 -> the first token_id will be 0,
  edition 1 -> the first token_id will be 50
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

type license =
[@layout:comb]
{
    upgradeable : bool;
    hash : bytes;
}

type edition_metadata =
[@layout:comb]
{
    edition_info: (string, bytes) map;
    total_edition_number: nat;
    license : license;
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

``minter`` : Minter of the edition (Tezos.get_sender())

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

``revoke_minting`` : If set to true the contract will be blocked for ever and the serie will be sealed



## Entrypoints

The different entrypoints of the contract are define by:

``` ocaml
type editions_entrypoints =
    |   Admin of admin_entrypoints
    |   FA2 of fa2_entry_points
    |   Mint_editions of mint_edition_param list
    |   Upgrade_license of license_param
    |   Update_metadata of bytes
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


### Upgrade_license

The `Upgrade_license` entrypoint is responsible to update the license attached to the nft at anytime by the minter of the token (the person holding the copyright for it).


### Burn_token

The `Burn_token` entrypoint will remove token from the ledger big_map. and is only accessible from the owner of the token
