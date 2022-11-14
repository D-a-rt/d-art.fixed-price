# Permission manager contract 

The permission manager is responsible to hold the addresses that will have access to the D A:RT system (admins, artists and galleries). The only purpose is to have a unique contract responsible to manage the permission of the ecosystem. Therefore the storage and the entrypoints are straightforward.

## Storage definition

This section is responsible to list and explain the storage of the contract.

```ocaml
type storage =
{
    admins: (address, unit) map;
    minters: (address, unit) big_map;
    galleries: (address, unit) big_map;
    metadata: (string, bytes) big_map;
}
```

### admins 

The map containing all the admin of the contract, each address of this map has the same rights over the contract.

### minters

The big_map containing the minters having the right to access the serie factory contract as well as minting one token on the legacy D A:RT contract (FA2 editions version).

### galleries

The big_map containing the galleries having the right to access the gallery factory contract and create their own curation on it.

### metadata

The metadata of the deployed contract.

## Entrypoints

The different entrypoint of the contract are defined by:

```ocaml
type art_permission_manager = 
    |   Add_minter of address
    |   Remove_minter of address
    |   Add_gallery of address
    |   Remove_gallery of address
    |   Add_admin of address
    |   Remove_admin of address
```

### Add & Remove minter

These two entrypoints are responsible to manage the minters, they should fail if amount is sent to the contract, if it sis called by a non admin address or if minter already registered in the big_map, otherwise should pass.

### Add & Remove gallery

These two entrypoints are responsible to manage the galleries, they should fail if amount is sent to the contract, if it sis called by a non admin address or if gallery already registered in the big_map, otherwise should pass.

### Add & Remove admin

These two entrypoints are responsible to add and remove address from the admin map. They should fail if not access using an admin address, it should not be possible to add two times the same admin and not possible to remove an admin if there is only one address in the map.