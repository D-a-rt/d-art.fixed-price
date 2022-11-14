
// Storage

type storage =
{
    admins: (address, unit) map;
    minters: (address, unit) big_map;
    galleries: (address, unit) big_map;
    metadata: (string, bytes) big_map;
}
