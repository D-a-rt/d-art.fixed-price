#include "fixed_price_interface.mligo"
#include "fixed_price_check.mligo"
#include "admin_main.mligo"
#include "../common.mligo"

type fix_price_entrypoints =
    | Admin of admin_entrypoints
    | SaleConfiguration of sale_configuration
    | SaleEdition of sale_edition
    | SaleDeletion of sale_deletion
    | DropConfiguration of drop_configuration
    | DropRegistration of drop_registration
    | BuyFixedPriceToken of buy_token
    | BuyDroppedToken of buy_token

// Fixed price sales functions
// Only the preconfigure_token_sale function needs to be protected 
// buy verify_user the rest will be handle by the triggers

let preconfigure_token_sale (sale_configuration, storage : sale_configuration * storage) : return =
    let _wrong_amount : unit = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let _wrong_seller : unit = assert_msg (Tezos.sender = sale_configuration.seller, "Only seller can sell the token") in
    let _verify_user : unit = verify_user (sale_configuration.authorization_signature, storage) in

    let fa2_token_identifier : fa2_token_identifier = {
        fa2_address = sale_configuration.fa2_token.fa2_address;
        token_id = sale_configuration.fa2_token.token_id;
    } in

    let _fail_if_token_already_in_sale = fail_if_token_already_in_sale (fa2_token_identifier, sale_configuration.seller, storage) in
    let _fail_if_token_sale_configuration_wrong = fail_if_token_sale_configuration_wrong (sale_configuration.fa2_token, sale_configuration.price) in
    let _fail_if_allowlist_to_big = fail_if_allowlist_to_big (sale_configuration.fa2_token, sale_configuration.allowlist) in

    let fixed_price_sale_values : fixed_price_sale = {
        price = sale_configuration.price;
        token_amount = sale_configuration.fa2_token.amount;
        allowlist = sale_configuration.allowlist;
    } in

    let new_preconfigured_sales = Big_map.add (fa2_token_identifier, sale_configuration.seller) fixed_price_sale_values storage.preconfigured_sales in
    let new_storage_with_preconfigured_sales = { storage with preconfigured_sales = new_preconfigured_sales } in
    
    let fa2_transfer : operation = transfer_token_in_contract(sale_configuration.fa2_token, Tezos.sender, Tezos.self_address) in
    let new_storage : storage = mark_message_as_used (sale_configuration.authorization_signature, new_storage_with_preconfigured_sales) in
    
    ([fa2_transfer], new_storage)
    
let edit_token_sale (sale_edition, storage : sale_edition * storage ) : return =
    let _wrong_amount : unit = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let _wrong_seller : unit = assert_msg (Tezos.sender = sale_edition.seller, "Only seller can edit the token sale") in

    let fa2_token_identifier : fa2_token_identifier = {
        fa2_address = sale_edition.fa2_token.fa2_address;
        token_id = sale_edition.fa2_token.token_id;
    } in

    let _fail_if_token_sale_not_configured : unit = fail_if_token_sale_not_configured (fa2_token_identifier, storage) in
    let _fail_if_token_sale_configuration_wrong : unit = fail_if_token_sale_configuration_wrong (sale_edition.fa2_token, sale_edition.price) in
    let _fail_if_allowlist_to_big : unit = fail_if_allowlist_to_big (sale_edition.fa2_token, sale_edition.allowlist) in

    let fixed_price_sale_values : fixed_price_sale = {
        price = sale_edition.price;
        token_amount = sale_edition.fa2_token.amount;
        allowlist = sale_edition.allowlist;
    } in

    let new_preconfigured_sales = Big_map.update (fa2_token_identifier, sale_edition.seller) (Some fixed_price_sale_values) storage.preconfigured_sales in
    let new_storage = { storage with preconfigured_sales = new_preconfigured_sales } in

    ([] : operation list), new_storage

let delete_token_sale (sale_deletion, storage : sale_deletion * storage) : return =
    let _wrong_amount : unit = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let _wrong_seller : unit = assert_msg (Tezos.sender = sale_deletion.seller, "Only seller can remove the token from sale") in

    let _fail_if_token_sale_not_configured : unit = fail_if_token_sale_not_configured (sale_deletion.fa2_token_identifier, storage) in
    
    let preconfigured_sale : fixed_price_sale = get_fixed_price_sale_in_maps (sale_deletion.fa2_token_identifier, sale_deletion.seller, storage) in
    
    let new_preconfigured_sales = Big_map.remove (sale_deletion.fa2_token_identifier, sale_deletion.seller) storage.preconfigured_sales in
    let new_storage = { storage with preconfigured_sales = new_preconfigured_sales } in

    let fa2_token : fa2_token = {
        fa2_address = sale_deletion.fa2_token_identifier.fa2_address;
        token_id = sale_deletion.fa2_token_identifier.token_id;
        amount = preconfigured_sale.token_amount;
    } in

    let fa2_transfer : operation = transfer_token_in_contract (fa2_token, Tezos.self_address, Tezos.sender) in
    
    ([fa2_transfer], new_storage)

// Drops functions

let create_token_drop (drop_configuration, storage : drop_configuration * storage) : return =
    let _wrong_amount : unit = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let _wrong_seller : unit = assert_msg (Tezos.sender = drop_configuration.seller, "Only seller can create a drop") in
    let _verify_user : unit = verify_user (drop_configuration.authorization_signature, storage) in

    let fa2_token_identifier : fa2_token_identifier = {
        fa2_address = drop_configuration.fa2_token.fa2_address;
        token_id = drop_configuration.fa2_token.token_id;
    } in

    let _fail_if_wrong_drop_date : unit = fail_if_wrong_drop_date drop_configuration.drop_date in
    let _fail_if_wrong_sale_duration : unit = fail_if_wrong_sale_duration drop_configuration.sale_duration in
    let _fail_if_allowlist_to_big : unit = fail_if_allowlist_to_big (drop_configuration.fa2_token, drop_configuration.allowlist) in
    let _fail_if_allowlist_and_registration_not_configured_properly : unit = fail_if_allowlist_and_registration_not_configured_properly (drop_configuration.allowlist, drop_configuration.registration) in
    let _fail_if_token_already_been_dropped : unit = fail_if_token_already_been_dropped (fa2_token_identifier, storage) in
    let _fail_if_sender_is_not_drop_seller : unit = fail_if_sender_is_not_drop_seller storage in

    let empty_registration_list : (address, unit) map = Map.empty in

    let fixed_price_drop : fixed_price_drop = {
        price = drop_configuration.price;
        token_amount = drop_configuration.fa2_token.amount;
        registration_list = empty_registration_list ;
        registration = drop_configuration.registration;
        allowlist = drop_configuration.allowlist;
        drop_date = drop_configuration.drop_date;
        sale_duration = drop_configuration.sale_duration;
    } in
    
    let new_drops = Big_map.add (fa2_token_identifier, drop_configuration.seller) fixed_price_drop storage.drops in
    let new_storage_with_drops = { storage with drops = new_drops } in
    let new_storage_with_fa2_dropped = { storage with fa2_dropped = Big_map.add fa2_token_identifier unit storage.fa2_dropped } in

    let fa2_transfer : operation = transfer_token_in_contract (drop_configuration.fa2_token, Tezos.self_address, Tezos.sender) in
    let new_storage : storage = mark_message_as_used (drop_configuration.authorization_signature, new_storage_with_drops) in

    [fa2_transfer], new_storage

let register_to_drop ( drop_registration, storage : drop_registration * storage ) : return =
    let _wrong_amount : unit = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let _wrong_sender : unit = assert_msg (Tezos.sender <> drop_registration.seller, "Seller can not register for a drop") in
    let _verify_user : unit = verify_user (drop_registration.authorization_signature, storage) in

    let _fail_if_drop_not_present_or_sender_already_registered_to_drop : unit = fail_if_drop_not_present_or_sender_already_registered_to_drop (drop_registration, storage) in
    let _fail_if_registration_period_over : unit = fail_if_registration_period_over (drop_registration, storage) in
    
    let fixed_price_drop : fixed_price_drop = get_fixed_price_drop_in_map (drop_registration.fa2_token_identifier, drop_registration.seller, storage) in
    let _fail_if_registration_list_sold_out : unit = fail_if_registration_list_sold_out (fixed_price_drop, storage) in

    let new_registration_list : (address, unit) map = Map.add Tezos.sender unit fixed_price_drop.registration_list in
    let new_fixed_price_drop : fixed_price_drop = { fixed_price_drop with registration_list = new_registration_list } in
    
    let new_drops_storage : drops_storage = Big_map.update (drop_registration.fa2_token_identifier, drop_registration.seller) (Some new_fixed_price_drop) storage.drops in
    let new_storage_with_drops : storage = { storage with drops = new_drops_storage } in

    let new_storage : storage = mark_message_as_used (drop_registration.authorization_signature, new_storage_with_drops) in

    ([] : operation list), new_storage

let buy_token_from_preconfigured_sale (fa2_token_identifier, buy_token, fixed_price_sale, storage : fa2_token_identifier * buy_token * fixed_price_sale * storage) : return =
 
    let operation_list : operation list = perform_sale_operation (buy_token, fixed_price_sale.price, storage) in

    let new_fixed_price_sale = { 
        fixed_price_sale with 
        token_amount = abs(fixed_price_sale.token_amount - buy_token.fa2_token.amount)
    } in

    if new_fixed_price_sale.token_amount = 0n
    then operation_list, { storage with preconfigured_sales = Big_map.remove (fa2_token_identifier, buy_token.seller) storage.preconfigured_sales }
    else operation_list, { storage with preconfigured_sales = Big_map.remove (fa2_token_identifier, buy_token.seller) storage.preconfigured_sales; sales = Big_map.add (fa2_token_identifier, buy_token.seller) new_fixed_price_sale storage.sales; }

let buy_token_from_sale (fa2_token_identifier, buy_token, fixed_price_sale, storage : fa2_token_identifier * buy_token * fixed_price_sale * storage) : return =
 
    let operation_list : operation list = perform_sale_operation (buy_token, fixed_price_sale.price, storage) in

    let new_fixed_price_sale = { 
        fixed_price_sale with 
        token_amount =  abs (fixed_price_sale.token_amount - buy_token.fa2_token.amount)
    } in

    if new_fixed_price_sale.token_amount = 0n
    then operation_list, { storage with sales = Big_map.remove (fa2_token_identifier, buy_token.seller) storage.sales } 
    else operation_list, { storage with sales = Big_map.update (fa2_token_identifier, buy_token.seller) (Some new_fixed_price_sale) storage.sales } 

let buy_fixed_price_token (buy_token, storage : buy_token * storage) : return =
    let _seller_can_not_be_buyer : unit = assert_msg (Tezos.sender <> buy_token.seller, "Seller can not buy a token") in    
    let _verify_user : unit = verify_user (buy_token.authorization_signature, storage) in

    let fa2_token_identifier : fa2_token_identifier = {
        fa2_address = buy_token.fa2_token.fa2_address;
        token_id = buy_token.fa2_token.token_id;
    } in

    let concerned_fixed_price_sale : fixed_price_sale = get_fixed_price_sale_in_maps (fa2_token_identifier, buy_token.seller, storage) in
    let _fail_if_not_enough_token_available : unit = fail_if_not_enough_token_available (concerned_fixed_price_sale.token_amount, buy_token) in 
    let _fail_if_token_amount_to_high_for_private_sale : unit = fail_if_token_amount_to_high_for_private_sale (concerned_fixed_price_sale, buy_token) in
    let _fail_if_sender_not_authorized_for_fixed_price_sale : unit = fail_if_sender_not_authorized_for_fixed_price_sale concerned_fixed_price_sale in

    let new_storage : storage = mark_message_as_used (buy_token.authorization_signature, storage) in

    if token_in_preconfigured_sale (fa2_token_identifier, buy_token.seller, new_storage)
    then buy_token_from_preconfigured_sale (fa2_token_identifier, buy_token, concerned_fixed_price_sale, new_storage)
    else buy_token_from_sale (fa2_token_identifier, buy_token, concerned_fixed_price_sale, new_storage)

let buy_dropped_token (buy_token, storage : buy_token * storage) : return =
    let _seller_can_not_be_buyer : unit = assert_msg (Tezos.sender <> buy_token.seller, "Seller can not buy a token") in    
    let _verify_user : unit = verify_user (buy_token.authorization_signature, storage) in

    let fa2_token_identifier : fa2_token_identifier = {
        fa2_address = buy_token.fa2_token.fa2_address;
        token_id = buy_token.fa2_token.token_id;
    } in

    let concerned_fixed_price_drop : fixed_price_drop = get_fixed_price_drop_in_map (fa2_token_identifier, buy_token.seller, storage) in
    let _fail_if_drop_date_not_met : unit = fail_if_drop_date_not_met concerned_fixed_price_drop in
    let _fail_if_not_enough_token_available : unit = fail_if_not_enough_token_available (concerned_fixed_price_drop.token_amount, buy_token) in 
    let _fail_if_sender_not_authorized_for_fixed_price_drop : unit = fail_if_sender_not_authorized_for_fixed_price_drop concerned_fixed_price_drop in
    let _fail_if_token_amount_to_high_for_private_drop : unit = fail_if_token_amount_to_high_for_private_drop (concerned_fixed_price_drop, buy_token) in
    let _fail_if_token_amount_to_high_for_registration_drop : unit = fail_if_token_amount_to_high_for_registration_drop (concerned_fixed_price_drop, buy_token) in
    
    // TODO fail during registration period if sender wants to buy more token than available for the amount of person registered or participating at a private sale or drop
    // example : 1000 token 100 registered -> 10 tokens max per buyers (address)

    let new_fixed_price_drop = { 
        concerned_fixed_price_drop with 
        token_amount =  abs (concerned_fixed_price_drop.token_amount - buy_token.fa2_token.amount)
    } in

    let new_drops : drops_storage = if new_fixed_price_drop.token_amount = 0n
    then Big_map.remove (fa2_token_identifier, buy_token.seller) storage.drops
    else Big_map.update (fa2_token_identifier, buy_token.seller) (Some(new_fixed_price_drop)) storage.drops in

    let new_storage_with_drops = { storage with drops = new_drops } in

    let operation_list : operation list = perform_sale_operation (buy_token, new_fixed_price_drop.price, storage) in
    let new_storage : storage = mark_message_as_used (buy_token.authorization_signature, new_storage_with_drops) in

    operation_list, new_storage

let fixed_price_tez_main (p , storage : fix_price_entrypoints * storage) : return = match p with
    | Admin admin_param -> admin_main (admin_param, storage)
    
    // Fixed price sales entrypoints
    | SaleConfiguration sale_configuration -> preconfigure_token_sale(sale_configuration, storage)
    | SaleEdition edited_sale_configuration -> edit_token_sale(edited_sale_configuration, storage)
    | SaleDeletion sale_information -> delete_token_sale(sale_information, storage)
    
    // Drops entrypoints
    | DropConfiguration drop_configuration -> create_token_drop(drop_configuration, storage)
    | DropRegistration registration_param -> register_to_drop(registration_param, storage)

    // Buy token in any sales or drops
    | BuyFixedPriceToken buy_token -> buy_fixed_price_token(buy_token, storage)
    | BuyDroppedToken buy_token -> buy_dropped_token(buy_token, storage)