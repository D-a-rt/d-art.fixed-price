#include "fixed_price_interface.mligo"
#include "../common.mligo"
#include "fixed_price_check.mligo"
#include "admin_main.mligo"

type fix_price_entrypoints =
    | Admin of admin_entrypoints
    | CreateSale of sale_configuration
    | UpdateSale of sale_edition
    | DeleteSale of sale_deletion
    | ConfigureDrop of drop_configuration
    | RegisterToDrop of drop_registration
    | BuyFixedPriceToken of buy_token
    | BuyDroppedToken of buy_token

// Fixed price sales functions
// Only the preconfigure_token_sale function needs to be protected
// buy verify_user the rest will be handle by the triggers

let create_sale (sale_info, storage : sale_configuration * storage) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let () = assert_msg (Tezos.sender = sale_info.seller, "Only owner can create a sale") in
    let () = assert_msg (sale_info.price <= 0mutez, "PRICE_SHOULD_BE_GREATER_THAN_0" )
    let () = assert_msg (sale_info.fa2_token.amount <= 0n, "AMOUNT_SHOULD_BE_GREATER_THAN_0" )

    let () = assert_wrong_allowlist (sale_info.fa2_token, sale_info.allowlist) in

    let fixed_price_sale_values : fixed_price_sale = {
        price = sale_info.price;
        token_amount = sale_info.fa2_token.amount;
        allowlist = sale_info.allowlist;
    } in

    let new_storage = { storage with for_sale =
        Big_map.add ({ address = sale_info.fa2_token.address; id = sale_info.fa2_token.id; }, sale_info.seller) fixed_price_sale_values storage.for_sale } in

    let fa2_transfer : operation = transfer_token_to_contract (sale_info.fa2_token, Tezos.sender, Tezos.self_address) in

    ([fa2_transfer], new_storage)

let update_sale (sale_edition, storage : sale_edition * storage ) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let () = assert_msg (Tezos.sender = sale_edition.seller, "Only seller can edit the token sale") in

    let fa2_token_identifier : fa2_token_identifier = {
        address = sale_edition.fa2_token.address;
        id = sale_edition.fa2_token.id;
    } in

    let () = fail_if_token_sale_not_configured (fa2_token_identifier, storage) in
    let () = fail_if_token_sale_configuration_wrong (sale_edition.fa2_token, sale_edition.price) in
    let () = assert_wrong_allowlist (sale_edition.fa2_token, sale_edition.allowlist) in

    let fixed_price_sale_values : fixed_price_sale = {
        price = sale_edition.price;
        token_amount = sale_edition.fa2_token.amount;
        allowlist = sale_edition.allowlist;
    } in

    let new_preconfigured_sales = Big_map.update (fa2_token_identifier, sale_edition.seller) (Some fixed_price_sale_values) storage.for_sale in
    let new_storage = { storage with for_sale = new_preconfigured_sales } in

    ([] : operation list), new_storage

let delete_sale (sale_deletion, storage : sale_deletion * storage) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let () = assert_msg (Tezos.sender = sale_deletion.seller, "Only seller can remove the token from sale") in

    let () = fail_if_token_sale_not_configured (sale_deletion.fa2_token_identifier, storage) in

    let preconfigured_sale : fixed_price_sale = get_fixed_price_sale_in_maps (sale_deletion.fa2_token_identifier, sale_deletion.seller, storage) in

    let new_preconfigured_sales = Big_map.remove (sale_deletion.fa2_token_identifier, sale_deletion.seller) storage.for_sale in
    let new_storage = { storage with for_sale = new_preconfigured_sales } in

    let fa2_token : fa2_token = {
        address = sale_deletion.fa2_token_identifier.address;
        id = sale_deletion.fa2_token_identifier.id;
        amount = preconfigured_sale.token_amount;
    } in

    let fa2_transfer : operation = transfer_token_in_contract (fa2_token, Tezos.self_address, Tezos.sender) in

    ([fa2_transfer], new_storage)

// Drops functions

let create_token_drop (drop_configuration, storage : drop_configuration * storage) : return =
    let () = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let () = assert_msg (Tezos.sender = drop_configuration.seller, "Only seller can create a drop") in
    let () = verify_user (drop_configuration.authorization_signature, storage) in

    let fa2_token_identifier : fa2_token_identifier = {
        address = drop_configuration.fa2_token.address;
        id = drop_configuration.fa2_token.id;
    } in

    let () = fail_if_wrong_drop_date drop_configuration.drop_date in
    let () = fail_if_wrong_sale_duration drop_configuration.sale_duration in
    let () = fail_if_allowlist_to_big (drop_configuration.fa2_token, drop_configuration.allowlist) in
    let () = fail_if_allowlist_and_registration_not_configured_properly (drop_configuration.allowlist, drop_configuration.registration) in
    let () = fail_if_token_already_been_dropped (fa2_token_identifier, storage) in
    let () = fail_if_sender_is_not_drop_seller storage in

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
    let () = assert_msg (Tezos.amount = 0mutez, "Amount sent must be 0mutez") in
    let () = assert_msg (Tezos.sender <> drop_registration.seller, "Seller can not register for the drop") in
    let () = verify_user (drop_registration.authorization_signature, storage) in

    let () = fail_if_drop_not_present_or_sender_already_registered_to_drop (drop_registration, storage) in
    let () = fail_if_registration_period_over (drop_registration, storage) in

    let fixed_price_drop : fixed_price_drop = get_fixed_price_drop_in_map (drop_registration.fa2_token_identifier, drop_registration.seller, storage) in
    let () = fail_if_registration_list_sold_out (fixed_price_drop, storage) in

    let new_registration_list : (address, unit) map = Map.add Tezos.sender unit fixed_price_drop.registration_list in
    let new_fixed_price_drop : fixed_price_drop = { fixed_price_drop with registration_list = new_registration_list } in

    let new_drops_storage : drops_storage = Big_map.update (drop_registration.fa2_token_identifier, drop_registration.seller) (Some new_fixed_price_drop) storage.drops in
    let new_storage_with_drops : storage = { storage with drops = new_drops_storage } in

    let new_storage : storage = mark_message_as_used (drop_registration.authorization_signature, new_storage_with_drops) in

    ([] : operation list), new_storage

let buy_token_from_sale (fa2_token_identifier, buy_token, fixed_price_sale, storage : fa2_token_identifier * buy_token * fixed_price_sale * storage) : return =

    let operation_list : operation list = perform_sale_operation (buy_token, fixed_price_sale.price, storage) in

    let new_fixed_price_sale = {
        fixed_price_sale with
        token_amount =  abs (fixed_price_sale.token_amount - buy_token.fa2_token.amount)
    } in

    if new_fixed_price_sale.token_amount = 0n
    then operation_list, { storage with for_sale = Big_map.remove (fa2_token_identifier, buy_token.seller) storage.for_sale }
    else operation_list, { storage with for_sale = Big_map.update (fa2_token_identifier, buy_token.seller) (Some new_fixed_price_sale) storage.for_sale }

let buy_fixed_price_token (buy_token, storage : buy_token * storage) : return =
    let () = assert_msg (Tezos.sender <> buy_token.seller, "Seller can not buy the token") in
    let () = verify_user (buy_token.authorization_signature, storage) in

    let fa2_token_identifier : fa2_token_identifier = {
        address = buy_token.fa2_token.address;
        id = buy_token.fa2_token.id;
    } in

    let concerned_fixed_price_sale : fixed_price_sale = get_fixed_price_sale_in_maps (fa2_token_identifier, buy_token.seller, storage) in
    let () = fail_if_not_enough_token_available (concerned_fixed_price_sale.token_amount, buy_token) in
    let () = fail_if_token_amount_to_high_for_private_sale (concerned_fixed_price_sale, buy_token) in
    let () = fail_if_sender_not_authorized_for_fixed_price_sale concerned_fixed_price_sale in

    // TODO delete buyers from the map when the maximum amount of token available is met

    let new_storage : storage = mark_message_as_used (buy_token.authorization_signature, storage) in

    buy_token_from_sale (fa2_token_identifier, buy_token, concerned_fixed_price_sale, new_storage)

let buy_dropped_token (buy_token, storage : buy_token * storage) : return =
    let () = assert_msg (Tezos.sender <> buy_token.seller, "Seller can not buy the token") in
    let () = verify_user (buy_token.authorization_signature, storage) in

    let fa2_token_identifier : fa2_token_identifier = {
        address = buy_token.fa2_token.address;
        id = buy_token.fa2_token.id;
    } in

    let concerned_fixed_price_drop : fixed_price_drop = get_fixed_price_drop_in_map (fa2_token_identifier, buy_token.seller, storage) in

    let () = fail_if_drop_date_not_met concerned_fixed_price_drop in
    let () = fail_if_not_enough_token_available (concerned_fixed_price_drop.token_amount, buy_token) in
    let () = fail_if_sender_not_authorized_for_fixed_price_drop concerned_fixed_price_drop in
    let () = fail_if_token_amount_to_high_for_private_drop (concerned_fixed_price_drop, buy_token) in
    let () = fail_if_token_amount_to_high_for_registration_drop (concerned_fixed_price_drop, buy_token) in

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
    | CreateSale sale_info -> create_sale(sale_info, storage)
    | UpdateSale updated_sale -> update_sale(updated_sale, storage)
    | DeleteSale token_info -> delete_sale(token_info, storage)

    // Drops entrypoints
    | ConfigureDrop drop_configuration -> create_token_drop(drop_configuration, storage)
    | RegisterToDrop registration_param -> register_to_drop(registration_param, storage)

    // Buy token in any sales or drops
    | BuyFixedPriceToken buy_token -> buy_fixed_price_token(buy_token, storage)
    | BuyDroppedToken buy_token -> buy_dropped_token(buy_token, storage)


// 1000 token 100 buyers in the list max 10 each