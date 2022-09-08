// Create Serie entrypoint

type create_serie_entrypoint =
[@layout:comb]
{
    metadata: bytes;
}

// Invite & Revoke admin invitation
type admin_invitation_param = 
[@layout:comb]
{
    new_admin: address
}

// Accept || Refuse admin invitation
type admin_response_param = 
[@layout:comb]
{
    accept: bool
}

// Storage

type serie = 
[@layout:comb]
{
    address: address;
    minter: address;
}

type admin_storage = {
    admin: address;
    pending_admin: address option;
}


type serie_factory_storage =
{
    admin: address;
    origination_paused: bool;
    minters: (address, unit) big_map;
    series : (nat, serie) big_map;
    metadata: (string, bytes) big_map;
    next_serie_id: nat;
}
