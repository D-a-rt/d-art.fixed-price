// Create Serie entrypoint
type create_entrypoint =
[@layout:comb]
{
    metadata: bytes;
}

type update_manager_entrypoint =
[@layout:comb]
{
    new_manager: address;
}

// Storage
type serie = 
[@layout:comb]
{
    address: address;
    minter: address;
}

type admin = address

type storage =
{
    admin: address;
    permission_manager: address;
    series : (nat, serie) big_map;
    galleries : (admin, address) big_map;
    metadata: (string, bytes) big_map;
    next_serie_id: nat;
}
