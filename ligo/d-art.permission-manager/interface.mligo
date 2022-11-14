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

type storage =
{
    admins: (address, unit) map;
    minters: (address, unit) big_map;
    galleries: (address, unit) big_map;
    metadata: (string, bytes) big_map;
}
