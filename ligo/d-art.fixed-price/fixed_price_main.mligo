#include "admin_main.mligo"

type fixed_price_entrypoints =
    | Admin of admin_entrypoints
    | Create_sales of sale_configuration
    | Update_sales of sale_info list
    | Revoke_sales of revoke_sales_param
    | Create_drops of drop_configuration
    | Revoke_drops of revoke_drops_param
    | Buy_fixed_price_token of buy_token
    | Buy_dropped_token of buy_token

// Fixed price sales functions

let create_sales (sale_configuration, storage : sale_configuration * storage) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    let () = assert_msg (not storage.admin.contract_will_update, "WILL_BE_DEPRECATED") in
    let () = verify_signature (sale_configuration.authorization_signature, storage) in

    let create_sale : (storage * sale_info ) -> storage =
        fun (strg, sale_param : storage * sale_info ) ->
            let () = assert_msg (sale_param.price >= 100000mutez, "Price should be at least 0.1tez" ) in
            
            let () = match sale_param.buyer with
                    Some buyer -> assert_msg (buyer <> Tezos.sender, "BUYER_CANNOT_BE_SELLER" )
                |   None -> unit
            in

            let fixed_price_sale_values : fixed_price_sale = {
                price = sale_param.price;
                buyer = sale_param.buyer;
            } in

            let () = assert_msg (not Big_map.mem (sale_param.fa2_token, Tezos.sender) strg.for_sale, "ALREADY_ON_SALE") in

            {
                storage with
                for_sale = Big_map.add ({ address = sale_param.fa2_token.address; id = sale_param.fa2_token.id; }, Tezos.sender) fixed_price_sale_values strg.for_sale;
                admin.signed_message_used = Big_map.add sale_configuration.authorization_signature.message unit strg.admin.signed_message_used
            }
    in

    let new_storage = List.fold create_sale sale_configuration.sale_infos storage in
    ([] : operation list), new_storage

let update_sales (sale_infos, storage : sale_info list * storage ) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in

    let update_sale : (storage * sale_info ) -> storage =
        fun (strg, sale_param : storage * sale_info ) ->
            let () = assert_msg (sale_param.price >= 100000mutez, "Price should be at least 0.1tez" ) in
            let () = assert_msg (Big_map.mem (sale_param.fa2_token, Tezos.sender) strg.for_sale, "NOT_SELLER_OR_NOT_FOR_SALE") in

            let () = match sale_param.buyer with
                    Some buyer -> assert_msg (buyer <> Tezos.sender, "BUYER_CANNOT_BE_SELLER" )
                |   None -> unit
            in

            let fixed_price_sale_values : fixed_price_sale = {
                price = sale_param.price;
                buyer = sale_param.buyer;
            } in

           { storage with for_sale = Big_map.update (sale_param.fa2_token, Tezos.sender) (Some fixed_price_sale_values) strg.for_sale; }
    in
    let new_storage = List.fold update_sale sale_infos storage in
    ([] : operation list), new_storage

let revoke_sales (revoke_sales_param, storage : revoke_sales_param * storage) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in

    let revoke_sale : (storage * fa2_base) -> storage =
        fun (strg, fa2_b : storage * fa2_base ) ->
            let () = assert_msg (Big_map.mem (fa2_b, Tezos.sender) strg.for_sale, "NOT_SELLER_OR_NOT_FOR_SALE") in

            { storage with for_sale = Big_map.remove (fa2_b, Tezos.sender) strg.for_sale }
    in
    let new_strg =  List.fold revoke_sale revoke_sales_param.fa2_tokens storage in
    ([] : operation list), new_strg

let buy_fixed_price_token (buy_token, storage : buy_token * storage) : return =
    let () = assert_msg (Tezos.sender <> buy_token.seller, "SELLER_NOT_AUTHORIZED") in
    let () = verify_signature (buy_token.authorization_signature, storage) in

    let concerned_fixed_price_sale : fixed_price_sale = get_sale (buy_token.fa2_token, buy_token.seller, storage) in

    let () = fail_if_sender_not_authorized (concerned_fixed_price_sale.buyer) in
    let () = assert_msg (concerned_fixed_price_sale.price = Tezos.amount, "WRONG_PRICE_SPECIFIED") in

    let operation_list : operation list = perform_sale_operation (buy_token, concerned_fixed_price_sale.price, storage) in
    
    operation_list, { storage with for_sale = Big_map.remove (buy_token.fa2_token, buy_token.seller) storage.for_sale; admin.signed_message_used = Big_map.add buy_token.authorization_signature.message unit storage.admin.signed_message_used }
    

// Drop functions

let create_drops (drop_configuration, storage : drop_configuration * storage) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    let () = assert_msg (not storage.admin.contract_will_update, "WILL_BE_DEPRECATED") in
    let () = verify_signature (drop_configuration.authorization_signature, storage) in
    let () = assert_msg (Big_map.mem Tezos.sender storage.authorized_drops_seller, "NOT_AUTHORIZED_DROP_SELLER") in
    
    let create_drop : ( storage * drop_info ) -> storage =
        fun (strg, drop_param : storage * drop_info ) ->
            
            let () = assert_msg (drop_param.price >= 100000mutez, "Price should be at least 0.1tez" ) in
            let () = fail_if_wrong_drop_date (drop_param.drop_date) in

            let () = assert_msg (not Big_map.mem (drop_param.fa2_token, Tezos.sender) strg.drops, "ALREADY_DROPED") in
            let () = assert_msg (not Big_map.mem drop_param.fa2_token storage.fa2_dropped, "ALREADY_DROPED") in

            let fixed_price_drop : fixed_price_drop = {
                price = drop_param.price;
                drop_date = drop_param.drop_date;
            } in

            {
                storage with
                fa2_dropped = Big_map.add drop_param.fa2_token unit strg.fa2_dropped;
                drops = Big_map.add (drop_param.fa2_token, Tezos.sender) fixed_price_drop strg.drops;
                admin.signed_message_used = Big_map.add drop_configuration.authorization_signature.message unit strg.admin.signed_message_used
            } 
    in
    let new_storage = List.fold create_drop drop_configuration.drop_infos storage in
    ([] : operation list), new_storage

let revoke_drops (revoke_drops_param, storage : revoke_drops_param * storage) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in

    let revoke_drop : (storage * fa2_base) -> storage =
        fun (strg, fa2_b : storage * fa2_base ) ->

            let drop : fixed_price_drop = get_drop (fa2_b, Tezos.sender, strg) in
            // let () = assert_msg (drop.drop_date - 21600 > Tezos.now, "DROP_CANNOT_BE_REVOKED") in
            let () = assert_msg (Tezos.now > drop.drop_date + 84600 || drop.drop_date - 21600 > Tezos.now, "DROP_CANNOT_BE_REVOKED") in

            // Erase the token from drop
            if drop.drop_date - 21600 > Tezos.now 
            then { storage with drops = Big_map.remove (fa2_b, Tezos.sender) strg.drops; fa2_dropped = Big_map.remove fa2_b strg.fa2_dropped }
            else { storage with drops = Big_map.remove (fa2_b, Tezos.sender) strg.drops }

    in
    let new_storage = List.fold revoke_drop revoke_drops_param.fa2_tokens storage in
    ([]: operation list), new_storage

let buy_dropped_token (buy_token, storage : buy_token * storage) : return =
    let () = assert_msg (Tezos.sender <> buy_token.seller, "SELLER_NOT_AUTHORIZED") in
    let () = verify_signature (buy_token.authorization_signature, storage) in

    let concerned_fixed_price_drop : fixed_price_drop = get_drop (buy_token.fa2_token, buy_token.seller, storage) in

    let () = assert_msg (concerned_fixed_price_drop.price = Tezos.amount, "WRONG_PRICE_SPECIFIED") in
    let () = fail_if_drop_date_not_met concerned_fixed_price_drop in

    let operation_list : operation list = perform_sale_operation (buy_token, concerned_fixed_price_drop.price, storage) in

    let new_strg = { storage with drops = Big_map.remove (buy_token.fa2_token, buy_token.seller) storage.drops; admin.signed_message_used = Big_map.add buy_token.authorization_signature.message unit storage.admin.signed_message_used } in

    operation_list, new_strg


let fixed_price_tez_main (p , storage : fixed_price_entrypoints * storage) : return = match p with
    | Admin admin_param -> admin_main (admin_param, storage)

    // Fixed price sales entrypoints
    | Create_sales sale_configuration -> create_sales (sale_configuration, storage)
    | Update_sales sale_configuration -> update_sales (sale_configuration, storage)
    | Revoke_sales token_info -> revoke_sales (token_info, storage)

    // Drops entrypoints
    | Create_drops drop_configuration -> create_drops (drop_configuration, storage)
    | Revoke_drops drop_info -> revoke_drops (drop_info, storage)

    // Buy token in any sales or drops
    | Buy_fixed_price_token buy_token -> buy_fixed_price_token (buy_token, storage)
    | Buy_dropped_token buy_token -> buy_dropped_token (buy_token, storage)
