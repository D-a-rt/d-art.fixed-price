// Invite & Revoke admin invitation
type admin_invitation_param = 
{
    new_admin: address
}

// Accept || Refuse admin invitation
type admin_response_param = 
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
    admin_str: admin_storage;
    minters: (address, unit) big_map;
    galleries: (address, unit) big_map;
    metadata: (string, bytes) big_map;
}
