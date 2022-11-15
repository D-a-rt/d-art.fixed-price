#include "admin_main.mligo"

type fixed_price_entrypoints =
    | Admin of admin_entrypoints
    | Create_sales of sale_configuration
    | Update_sales of sale_info list
    | Revoke_sales of revoke_param
    | Create_drops of drop_configuration
    | Revoke_drops of revoke_param
    | Create_offer of offer_conf
    | Revoke_offer of offer_conf
    | Accept_offer of accept_offer
    | Buy_fixed_price_token of buy_token
    | Buy_dropped_token of buy_token

let create_offer (offer_conf, storage : offer_conf * storage) : return =
    let () = assert_msg (not storage.admin.contract_will_update, "WILL_BE_DEPRECATED") in
    let () = assert_msg (not Big_map.mem (offer_conf.fa2_token, Tezos.get_sender()) storage.offers, "OFFER_ALREADY_PLACED") in
    let () = fail_if_wrong_commodity (offer_conf.commodity, storage) in

    ([]: operation list), { storage with offers = Big_map.add (offer_conf.fa2_token, Tezos.get_sender()) offer_conf.commodity storage.offers }

let revoke_offer (offer_conf, storage : offer_conf * storage) : return =
    let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    match Big_map.find_opt (offer_conf.fa2_token, Tezos.get_sender()) storage.offers with
        |   None -> (failwith "NO_OFFER_PLACED" : return)
        |   Some offer_amt -> (
                let offer_ctr : unit contract = resolve_contract (Tezos.get_sender()) in
                (match offer_amt with | Tez price -> [Tezos.transaction unit price offer_ctr] | Fa2 _ -> ([] : operation list)), { storage with offers = Big_map.remove (offer_conf.fa2_token, Tezos.get_sender()) storage.offers }
            )

let accept_offer (accept_conf, storage : accept_offer * storage) : return =
    let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    let () = assert_msg (accept_conf.buyer <> Tezos.get_sender(), "BUYER_CANNOT_BE_SELLER") in
    match Big_map.find_opt (accept_conf.fa2_token, accept_conf.buyer) storage.offers with
        |   None -> (failwith "NO_OFFER_PLACED" : return)
        |   Some offer_amt -> (
                let operation_list : operation list = perform_sale_operation (accept_conf.fa2_token, Tezos.get_sender(), accept_conf.buyer, (None : address option), offer_amt, storage) in
                operation_list, { storage with offers = Big_map.remove (accept_conf.fa2_token, accept_conf.buyer) storage.offers }
            )

// Fixed price sales functions
let create_sales (sale_configuration, storage : sale_configuration * storage) : return =
    let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    let () = assert_msg (not storage.admin.contract_will_update, "WILL_BE_DEPRECATED") in
    let () = verify_signature (sale_configuration.authorization_signature, storage) in

    let create_sale : (storage * sale_info ) -> storage =
        fun (strg, sale_param : storage * sale_info ) ->
           let () = fail_if_wrong_commodity (sale_param.commodity, storage) in
            
            let () = match sale_param.buyer with
                    Some buyer -> assert_msg (buyer <> Tezos.get_sender(), "BUYER_CANNOT_BE_SELLER" )
                |   None -> unit
            in

            let fixed_price_sale_values : fixed_price_sale = {
                commodity = sale_param.commodity;
                buyer = sale_param.buyer;
            } in

            let () = assert_msg (not Big_map.mem (sale_param.fa2_token, Tezos.get_sender()) strg.for_sale, "ALREADY_ON_SALE") in

            {
                storage with
                for_sale = Big_map.add ({ address = sale_param.fa2_token.address; id = sale_param.fa2_token.id; }, Tezos.get_sender()) fixed_price_sale_values strg.for_sale;
                admin.signed_message_used = Big_map.add sale_configuration.authorization_signature.message unit strg.admin.signed_message_used
            }
    in

    let new_storage = List.fold create_sale sale_configuration.sale_infos storage in
    ([] : operation list), new_storage

let update_sales (sale_infos, storage : sale_info list * storage ) : return =
    let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in

    let update_sale : (storage * sale_info ) -> storage =
        fun (strg, sale_param : storage * sale_info ) ->
            let () = fail_if_wrong_commodity (sale_param.commodity, storage) in
            let () = assert_msg (Big_map.mem (sale_param.fa2_token, Tezos.get_sender()) strg.for_sale, "NOT_SELLER_OR_NOT_FOR_SALE") in

            let () = match sale_param.buyer with
                    Some buyer -> assert_msg (buyer <> Tezos.get_sender(), "BUYER_CANNOT_BE_SELLER" )
                |   None -> unit
            in

            let fixed_price_sale_values : fixed_price_sale = {
                commodity = sale_param.commodity;
                buyer = sale_param.buyer;
            } in

           { storage with for_sale = Big_map.update (sale_param.fa2_token, Tezos.get_sender()) (Some fixed_price_sale_values) strg.for_sale; }
    in
    let new_storage = List.fold update_sale sale_infos storage in
    ([] : operation list), new_storage

let revoke_sales (revoke_sales_param, storage : revoke_param * storage) : return =
    let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in

    let revoke_sale : (storage * fa2_base) -> storage =
        fun (strg, fa2_b : storage * fa2_base ) ->
            let () = assert_msg (Big_map.mem (fa2_b, Tezos.get_sender()) strg.for_sale, "NOT_SELLER_OR_NOT_FOR_SALE") in

            { storage with for_sale = Big_map.remove (fa2_b, Tezos.get_sender()) strg.for_sale }
    in
    let new_strg =  List.fold revoke_sale revoke_sales_param.fa2_tokens storage in
    ([] : operation list), new_strg

let buy_fixed_price_token (buy_token, storage : buy_token * storage) : return =
    let () = assert_msg (buy_token.buyer <> buy_token.seller, "SELLER_NOT_AUTHORIZED") in
    let () = verify_signature (buy_token.authorization_signature, storage) in

    let concerned_fixed_price_sale : fixed_price_sale = get_sale (buy_token.fa2_token, buy_token.seller, storage) in

    let () = fail_if_buyer_not_authorized (Tezos.get_sender(), concerned_fixed_price_sale.buyer) in
    let () = fail_if_wrong_price_specified (concerned_fixed_price_sale.commodity) in

    let operation_list : operation list = perform_sale_operation (buy_token.fa2_token, buy_token.seller, buy_token.buyer, buy_token.referrer, concerned_fixed_price_sale.commodity, storage) in
    
    operation_list, { storage with fa2_sold = Big_map.add buy_token.fa2_token unit storage.fa2_sold; for_sale = Big_map.remove (buy_token.fa2_token, buy_token.seller) storage.for_sale; admin.signed_message_used = Big_map.add buy_token.authorization_signature.message unit storage.admin.signed_message_used }

// Drop functions
let create_drops (drop_configuration, storage : drop_configuration * storage) : return =
    let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    let () = assert_msg (not storage.admin.contract_will_update, "WILL_BE_DEPRECATED") in
    let () = verify_signature (drop_configuration.authorization_signature, storage) in
    
    let create_drop : ( storage * drop_info ) -> storage =
        fun (strg, drop_param : storage * drop_info ) ->
            
            let () = fail_if_wrong_commodity (drop_param.commodity, storage) in
            let () = fail_if_wrong_drop_date (drop_param.drop_date) in

            let () = assert_msg (not Big_map.mem (drop_param.fa2_token, Tezos.get_sender()) strg.drops, "ALREADY_DROPED") in
            let () = assert_msg (not Big_map.mem drop_param.fa2_token storage.fa2_dropped, "ALREADY_DROPED") in
            let () = assert_msg (not Big_map.mem drop_param.fa2_token storage.fa2_sold, "CANNOT_DROP_ALREADY_SOLD_TOKEN") in

            let auhorized = is_authorized_drop_seller (Tezos.get_sender(), drop_param.fa2_token) in
            let () = assert_msg (auhorized = true , "NOT_AUTHORIZED_DROP_SELLER") in
            
            let fixed_price_drop : fixed_price_drop = {
                commodity = drop_param.commodity;
                drop_date = drop_param.drop_date;
            } in

            {
                storage with
                fa2_dropped = Big_map.add drop_param.fa2_token unit strg.fa2_dropped;
                drops = Big_map.add (drop_param.fa2_token, Tezos.get_sender()) fixed_price_drop strg.drops;
                admin.signed_message_used = Big_map.add drop_configuration.authorization_signature.message unit strg.admin.signed_message_used
            }
    in
    let new_storage = List.fold create_drop drop_configuration.drop_infos storage in
    ([] : operation list), new_storage

let revoke_drops (revoke_drops_param, storage : revoke_param * storage) : return =
    let () = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in

    let revoke_drop : (storage * fa2_base) -> storage =
        fun (strg, fa2_b : storage * fa2_base ) ->

            let drop : fixed_price_drop = get_drop (fa2_b, Tezos.get_sender(), strg) in
            // let () = assert_msg (drop.drop_date - 21600 > Tezos.get_now(), "DROP_CANNOT_BE_REVOKED") in
            let () = assert_msg (Tezos.get_now() > drop.drop_date + 84600 || drop.drop_date - 21600 > Tezos.get_now(), "DROP_CANNOT_BE_REVOKED") in

            // Erase the token from drop
            if drop.drop_date - 21600 > Tezos.get_now() 
            then { storage with drops = Big_map.remove (fa2_b, Tezos.get_sender()) strg.drops; fa2_dropped = Big_map.remove fa2_b strg.fa2_dropped }
            else { storage with drops = Big_map.remove (fa2_b, Tezos.get_sender()) strg.drops }

    in
    let new_storage = List.fold revoke_drop revoke_drops_param.fa2_tokens storage in
    ([]: operation list), new_storage

let buy_dropped_token (buy_token, storage : buy_token * storage) : return =
    let () = assert_msg (buy_token.buyer <> buy_token.seller, "SELLER_NOT_AUTHORIZED") in
    let () = verify_signature (buy_token.authorization_signature, storage) in

    let concerned_fixed_price_drop : fixed_price_drop = get_drop (buy_token.fa2_token, buy_token.seller, storage) in

    let () = fail_if_wrong_price_specified (concerned_fixed_price_drop.commodity) in
    let () = fail_if_drop_date_not_met concerned_fixed_price_drop in

    let operation_list : operation list = perform_sale_operation (buy_token.fa2_token, buy_token.seller, buy_token.buyer, buy_token.referrer, concerned_fixed_price_drop.commodity, storage) in
    let new_strg = { storage with fa2_sold = Big_map.add buy_token.fa2_token unit storage.fa2_sold; drops = Big_map.remove (buy_token.fa2_token, buy_token.seller) storage.drops; admin.signed_message_used = Big_map.add buy_token.authorization_signature.message unit storage.admin.signed_message_used } in

    operation_list, new_strg


let fixed_price_main (p , storage : fixed_price_entrypoints * storage) : return = match p with
    | Admin admin_param -> admin_main (admin_param, storage)

    | Create_offer offer_conf -> create_offer (offer_conf, storage)
    | Revoke_offer offer_conf -> revoke_offer (offer_conf, storage)
    | Accept_offer param -> accept_offer (param, storage)

    // Fixed price sales entrypoints
    | Create_sales sale_configuration -> create_sales (sale_configuration, storage)
    | Update_sales sale_configuration -> update_sales (sale_configuration, storage)
    | Revoke_sales revoke_param -> revoke_sales (revoke_param, storage)

    // Drops entrypoints
    | Create_drops drop_configuration -> create_drops (drop_configuration, storage)
    | Revoke_drops revoke_param -> revoke_drops (revoke_param, storage)

    // Buy token in any sales or drops
    | Buy_fixed_price_token buy_token -> buy_fixed_price_token (buy_token, storage)
    | Buy_dropped_token buy_token -> buy_dropped_token (buy_token, storage)
