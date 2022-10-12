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

type admin_storage = {
    admin: address;
    pending_admin: address option;
}

type storage =
{
    admin: admin_storage;
    origination_paused: bool;
    minters: (address, unit) big_map;
    // Bool to know if contract originated or not
    galleries: (address, bool) big_map;
    metadata: (string, bytes) big_map;
}
