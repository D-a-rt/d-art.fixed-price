#include "multi_nft_token_editions.mligo"

type royalties = 
[@layout:comb]
{
  royalty: nat;
  splits: split list;
}

[@view]
let is_minter (add, storage : address * editions_storage) : bool =
    match (Big_map.find_opt add storage.admin.minters ) with
            Some minter -> true
        |   None -> false

[@view]
let minter (token_id, storage : nat * editions_storage) : address =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> edition_metadata.minter
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : address)

[@view]
let royalty (token_id, storage : nat * editions_storage) : nat =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> edition_metadata.royalty
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : nat)

[@view]
let royalty_splits (token_id, storage : token_id * editions_storage) : royalties =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> ({
                royalty = edition_metadata.royalty;
                splits = edition_metadata.splits;
            }: royalties)

        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : royalties)

[@view]
let splits (token_id, storage : token_id * editions_storage) : split list =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata ->  edition_metadata.splits
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : split list)

[@view]
let royalty_distribution (token_id, storage : token_id * editions_storage) : (address * royalties) =
    let edition_id = token_id_to_edition_id (token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> (
                (edition_metadata.minter : address ),
                ({
                    royalty = edition_metadata.royalty;
                    splits = edition_metadata.splits;
                }: royalties))
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : (address * royalties))

[@view]
let token_metadata (token_id, storage: nat * editions_storage) : token_metadata =
  match (Big_map.find_opt token_id storage.assets.ledger) with
    | Some addr ->
            let edition_id = token_id_to_edition_id(token_id, storage) in
            (match (Big_map.find_opt edition_id storage.editions_metadata) with
            | Some edition_metadata -> ({
                  token_id = token_id;
                  token_info = Map.add "edition_number" (Bytes.pack(token_id - (edition_id * storage.max_editions_per_run) + 1n) ) edition_metadata.edition_info
               } : token_metadata)
            | None -> (failwith "FA2_TOKEN_UNDEFINED" : token_metadata))
    | None -> (failwith "FA2_TOKEN_UNDEFINED" : token_metadata)
