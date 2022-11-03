
# Serie factory contract

The contract is in the directory ligo/d-art.serie-factory and is responsible to manage the minters permission and originate new contracts for authorizewd minters that would like to have there own series


## Storage definition

This section is responsible to list and explain the storage of the fa2-editions contract.


``` ocaml

type serie_factory_storage =
{
    admin: admin_factory_storage;
    origination_paused: bool;
    minters: (address, unit) big_map;
    series : (nat, serie) big_map;
    metadata: (string, bytes) big_map;
    next_serie_id: nat;
}

```

## admin

The first field is `admin`:


``` ocaml
type admin_factory_storage = {
    admin: address;
    pending_admin: address option;
}

```

One admin and pending admin to be able to transfer the minter curation to another address (such as a contract).

## origination_paused

The second field is `origination_paused` and define if minters are able to originate contract or not, this is a field set by the admin (usefull in case we would like to upgrade to a new version of the contract).

## minters


``` ocaml
type storage =
{
    ...
    minters: (address, unit) big_map;
    ...
}

```

The list of authorized minters (can originate new contracts and give access to the A:RT - Original contract)

## series


``` ocaml
type storage =
[@layout:comb]
{
    ...
    series : (nat, serie) big_map;
    ...
}
```

The list of series that has been originated by the contract with the address of the originator.

### metadata

``` ocaml
type storage =
{
    ...
    metadata: (string, bytes) big_map;
    ...
}
```

The metadata of the contract

### next_serie_id

``` ocaml
type storage =
{
    ...
    next_serie_id: nat;
    ...
}
```

The next serie identifier.

## Entrypoints

The different entrypoints of the contract are define by:

``` ocaml
type art_serie_factory = 
    |   Admin of admin_factory_entrypoints
    |   Create_serie of create_entrypoint
    |   Accept_admin_invitation of admin_response_param 

```

### Admin

The `Admin` entrypoints are responsible for pausing the contract (only the minting entrypoint) and updating the manager contract responsible to give or revoke access to minters.

#### admin_entrypoints

``` ocaml
type admin_factory_entrypoints =
    |   Add_minter of address
    |   Remove_minter of address
    |   Pause_serie_creation of bool
    |   Send_admin_invitation of admin_invitation_param
    |   Revoke_admin_invitation of unit
```


##### Add_minter

Entrypoints in order to add minter to the list of authorized minters.

##### Remove_minter

Entrypoints in order to remove minter to the list of authorized minters.

##### Pause_serie_creation

Entrypoints in order to block the origination of new series by the minters.

##### Send_admin_invitation

Entrypoints in order to set a pending_admin to transfer the ownership of the contract.

##### Revoke_admin_invitation

Entrypoints in order to delete a pending_admin.


### Create_serie

The `Create_serie` entrypoints is the one responsible to originate new contracts and can only be access by the the addresses present in the minters big_map.


### Accept_admin_invitation

The `Accept_admin_invitation` is responsible to set the new pending admin as admin in case the invitation is accepted or remove the pending admin in case it's declined.
