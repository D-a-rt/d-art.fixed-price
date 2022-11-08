#include "multi_nft_token_editions.mligo"

type royalties = 
[@layout:comb]
{
  royalty: nat;
  splits: split list;
}

type commissions =
[@layout:comb]
{
  commission_pct: nat;
  splits: split list;
}

#if GALLERY_CONTRACT

[@view]
let commission_splits (token_id, storage : token_id * editions_storage) : commissions =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> ({
                commission_pct = edition_metadata.gallery_commission;
                splits = edition_metadata.gallery_commission_splits;
            } : commissions)

        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : commissions)

#endif

#if SERIE_CONTRACT

[@view]
let minter (_token_id, storage : nat * editions_storage) : address = storage.admin.admin

[@view]
let is_token_minter (param, storage : (address * token_id) * editions_storage) : bool =
    let edition_id = token_id_to_edition_id(param.1, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some _ -> 
                if storage.admin.admin = param.0
                then true
                else false
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : bool)

[@view]
let royalty_distribution (token_id, storage : token_id * editions_storage) : (address * royalties) =
    let edition_id = token_id_to_edition_id (token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> (
                (storage.admin.admin : address ),
                ({
                    royalty = edition_metadata.royalty;
                    splits = edition_metadata.splits;
                }: royalties))
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : (address * royalties))

#else

[@view]
let minter (token_id, storage : nat * editions_storage) : address =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> edition_metadata.minter
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : address)

[@view]
let is_token_minter (param, storage : (address * token_id) * editions_storage) : bool =
    let edition_id = token_id_to_edition_id(param.1, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> 
                if edition_metadata.minter = param.0
                then true
                else false
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : bool)

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

#endif

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
let token_metadata (token_id, storage: nat * editions_storage) : token_metadata =
  match (Big_map.find_opt token_id storage.assets.ledger) with
    | Some _ ->
            let edition_id = token_id_to_edition_id(token_id, storage) in
            (match (Big_map.find_opt edition_id storage.editions_metadata) with
            | Some edition_metadata -> ({
                  token_id = token_id;
                  token_info = Map.add "edition_number" (Bytes.pack(token_id - (edition_id * storage.max_editions_per_run) + 1n) ) edition_metadata.edition_info
               } : token_metadata)
            | None -> (failwith "FA2_TOKEN_UNDEFINED" : token_metadata))
    | None -> (failwith "FA2_TOKEN_UNDEFINED" : token_metadata)

[@view]
let is_unique_edition (token_id, storage: nat * editions_storage) : bool =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> if edition_metadata.total_edition_number > 1n then false else true
        |   None -> (failwith "FA2_TOKEN_UNDEFINED" : bool)

