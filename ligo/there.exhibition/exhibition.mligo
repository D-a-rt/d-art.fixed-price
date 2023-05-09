#include interface.mligo
#include common.mligo
#include admin.mligo
#include creator.mligo

type exhibition_entrypoints = 
    | Admin of admin_entrypoints
    | Creator of creator_entrypoints
    
