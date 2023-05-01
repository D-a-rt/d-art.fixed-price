# Permission manager contract 

The permission manager is responsible to hold the addresses that will have access to the D A:RT system (admin, artists and space_managers). The only purpose is to have a unique contract responsible to manage the permission of the ecosystem. Therefore the storage and the entrypoints are straightforward.

## Storage definition

This section is responsible to list and explain the storage of the contract.

```ocaml
type admin_storage = 
{
    admin: address;
    pending_admin: address option;
}

type storage =
{
    admin_str: admin_storage;
    minters: (address, unit) big_map;
    space_managers: (address, unit) big_map;
    metadata: (string, bytes) big_map;
}
```

### admin

admin storage containing current admin and pending one in case we will change

### minters

The big_map containing the minters having the right to access the serie factory contract as well as minting one token on the legacy D A:RT contract (FA2 editions version).

### space_managers

The big_map containing the space_managers having the right to access the space factory contract and create their own curation on it.

### metadata

The metadata of the deployed contract.

## Entrypoints

The different entrypoint of the contract are defined by:

```ocaml
type admin_factory_entrypoints =
    |   Add_minter of address
    |   Remove_minter of address
    |   Add_space_manager of address
    |   Remove_space_manager of address
    |   Send_admin_invitation of admin_invitation_param
    |   Revoke_admin_invitation of unit

type art_permission_manager = 
    |   Admin of admin_factory_entrypoints
    |   Accept_admin_invitation of admin_response_param
```

### Add & Remove minter

These two entrypoints are responsible to manage the minters, they should fail if amount is sent to the contract, if it sis called by a non admin address or if minter already registered in the big_map, otherwise should pass.

### Add & Remove space

These two entrypoints are responsible to manage the space_managers, they should fail if amount is sent to the contract, if it sis called by a non admin address or if space already registered in the big_map, otherwise should pass.

### Send_admin_invitation

Entrypoints in order to replace the pending_admin in the admin storage

### Revoke_admin_invitation

Entrypoints in order to remove the pending_admin in the admin storage

### Accept_admin_invitation

Entrypoints only accessible to the pending admin in order to accept invitation

## Views

This contract have two views:

`is_space_manager`: View responsible to return true if address is a space

`is_minter`: View responsible to return true if address is a minter

`is_admin`: View responsible to return true if address is admin