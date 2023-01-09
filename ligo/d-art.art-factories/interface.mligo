// Create Serie entrypoint
type create_entrypoint =
[@layout:comb]
{
    metadata: bytes;
    symbol: bytes;
}

// Storage
type serie = 
[@layout:comb]
{
    address: address;
    minter: address;
}

type admin = address

#if SPACE_CONTRACT

type storage =
{
    permission_manager: address;
    spaces : (admin, address) big_map;
    metadata: (string, bytes) big_map;
}

#else

type storage =
{
    permission_manager: address;
    series : (nat, serie) big_map;
    metadata: (string, bytes) big_map;
    next_serie_id: nat;
}

#endif