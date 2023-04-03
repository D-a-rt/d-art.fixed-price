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

#if SPACE_CONTRACT

[@view]
let commission_splits (token_id, storage : token_id * editions_storage) : commissions option =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> Some ({
                commission_pct = edition_metadata.space_commission;
                splits = edition_metadata.space_commission_splits;
            })
        |   None -> (None : commissions option)

#endif

#if SERIE_CONTRACT

[@view]
let minter (_token_id, storage : nat * editions_storage) : address = storage.admin.admin

[@view]
let is_token_minter (param, storage : (address * token_id) * editions_storage) : bool option =
    let edition_id = token_id_to_edition_id(param.1, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some _ -> 
                if storage.admin.admin = param.0
                then Some(True)
                else Some(False)
        |   None -> (None : bool option)

[@view]
let royalty_distribution (token_id, storage : token_id * editions_storage) : (address * royalties) option =
    let edition_id = token_id_to_edition_id (token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> Some (
                (storage.admin.admin : address ),
                ({
                    royalty = edition_metadata.royalty;
                    splits = edition_metadata.splits;
                }: royalties))
        |   None -> (None : (address * royalties) option)

#else

[@view]
let minter (token_id, storage : nat * editions_storage) : address option =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> Some (edition_metadata.minter)
        |   None -> (None : address option)

[@view]
let is_token_minter (param, storage : (address * token_id) * editions_storage) : bool option=
    let edition_id = token_id_to_edition_id(param.1, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> 
                if edition_metadata.minter = param.0
                then Some(True)
                else Some(False)
        |   None -> (None : bool option)

[@view]
let royalty_distribution (token_id, storage : token_id * editions_storage) : (address * royalties) option=
    let edition_id = token_id_to_edition_id (token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> Some (
                (edition_metadata.minter : address ),
                ({
                    royalty = edition_metadata.royalty;
                    splits = edition_metadata.splits;
                }: royalties))
        |   None -> (None : (address * royalties) option)

#endif

[@view]
let royalty (token_id, storage : nat * editions_storage) : nat option =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> Some (edition_metadata.royalty)
        |   None -> (None : nat option)

[@view]
let royalty_splits (token_id, storage : token_id * editions_storage) : royalties option =
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> Some ({
                royalty = edition_metadata.royalty;
                splits = edition_metadata.splits;
            })

        |   None -> (None : royalties option)

[@view]
let splits (token_id, storage : token_id * editions_storage) : (split list) option=
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> Some (edition_metadata.splits)
        |   None -> (None : (split list) option)

[@view]
let token_metadata (token_id, storage: nat * editions_storage) : token_metadata option =
  match (Big_map.find_opt token_id storage.assets.ledger) with
    | Some _ ->
            let edition_id = token_id_to_edition_id(token_id, storage) in
            (match (Big_map.find_opt edition_id storage.editions_metadata) with
            | Some edition_metadata -> (
                match (Big_map.find_opt "symbol" storage.metadata) with
                    | Some symbol -> Some ({
                        token_id = token_id;
                        token_info = Map.add "symbol" (symbol) (Map.add "license" (edition_metadata.license.hash) (Map.add "edition_number" (Bytes.pack(token_id - (edition_id * storage.max_editions_per_run) + 1n) ) edition_metadata.edition_info))
                    } : token_metadata)
                    | None -> Some ({
                        token_id = token_id;
                        token_info = Map.add "license" (edition_metadata.license.hash) (Map.add "edition_number" (Bytes.pack(token_id - (edition_id * storage.max_editions_per_run) + 1n) ) edition_metadata.edition_info)
                    } : token_metadata)
            )
            | None -> (None : token_metadata option))
    | None -> (None : token_metadata option)

[@view]
let is_unique_edition (token_id, storage: nat * editions_storage) : bool option=
    let edition_id = token_id_to_edition_id(token_id, storage) in
    match (Big_map.find_opt edition_id storage.editions_metadata) with
            Some edition_metadata -> if edition_metadata.total_edition_number > 1n then Some(False) else Some(True)
        |   None -> (None : bool option)
