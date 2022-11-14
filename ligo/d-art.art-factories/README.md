
# Art factories contract

The art factories contracts are both responsible to originate contract for authorized artists and galleries taking part of the D A:RT ecosystem.

The two type of contracts originated are :
- FA2 serie version [See contract](../d-art.fa2-editions/README.md#fa2-editions---originated-from-factory)
- FA2 gallery version [See contract](../d-art.fa2-editions/README.md#fa2-editions---originated-from-factory)

The serie_factory.mligo file represent the serie_factory
The gallery_factory.mligo file represent the gallery_factory


## Storage definition

This section is responsible to list and explain the storage of the two factory contracts.


``` ocaml

type serie_factory_storage =
{
    permission_manager: address;
    series : (nat, serie) big_map;
    metadata: (string, bytes) big_map;
    next_serie_id: nat;
}

type gallery_factory_storage =
{
    permission_manager: address;
    galleries: (admin, address) big_map;
    metadata: (string, bytes) big_map;
}

```

The two storage are very close to each other the main difference take place in the series and gallery big_map.
Galleries can only originate one contract that will represent their galleries and on which they will be able to curate their own artists. On the other hand artists can originate as many as series as they want.

### permission_manager: 
The address of the contract responsible to manage the permission for the origination of the contracts and the administration.

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



## series big_map

``` ocaml

type serie = 
[@layout:comb]
{
    address: address;
    minter: address;
}


type storage =
{
    ...
    series : (nat, serie) big_map;
    next_serie_id: nat;
    ...
}

```

The list of originated series by the artists, note next_serie_id in order to auto increment the keys of the big_map. The value is represented by the serie type that define the address of the originated contract and the address of the originator of this contract (here called minter).


## galleries big_map

``` ocaml

type admin = address

type storage =
{
    ...
    galleries : (admin, address) big_map;
    ...
}

```

The list of originated galleries by the gallerist, the key of the big_map is the admin of the contract and the value represent the address of the contract, using such structure enable us to prevent administrator from originating multiple contracts.


## Entrypoints

The different entrypoints of the contract are define by:

``` ocaml
#if SERIE_CONTRACT

type art_factory = 
    |   Create_serie of create_entrypoint
    |   Update_permission_manager of admin_response_param 


#else

type art_factory = 
    |   Create_gallery of create_entrypoint
    |   Update_permission_manager of admin_response_param 

#endif
```

### Create_serie

This entrypoint is the one responsible to originate the FA2 serie contract located [here](../d-art.fa2-editions/README.md#fa2-editions---originated-from-factory). It should fail if the sender is not an authorized minter by the permission_manager contract. it only takes bytes as param that should be the reference to the ipfs link of the contract metadata (Note: this param can be updated later within the FA2 serie contract)

### Update_permission_manager

This entrypoint is the one responsible to update the address of the permission manager contract in case a new version is deployed. It should fail if the sender of the transaction is not an admin. (Manage by the permission manager contract)
