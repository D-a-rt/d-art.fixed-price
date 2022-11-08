#include "storage.test.mligo"

// // This storage is based on the contract fa2_editions
// // you can find it at this link https://github.com/D-a-rt/d-art.fa2-editions
// // The type below have been taken on the same contract for convenience

// // Fail if buyer is seller
// let test_buy_fixed_price_token_seller_buyer =
//     let _, contract_t_add, _, _ = get_fixed_price_contract (false) in
//     let init_str = Test.get_storage contract_t_add in

//     let () = Test.set_source init_str.admin.address in
//     let contract = Test.to_contract contract_t_add in

//     let result = Test.transfer_to_contract contract
//         (Buy_fixed_price_token ({
//             fa2_token = ({
//                 id = 0n;
//                 address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
//             } : fa2_base);
//             seller = init_str.admin.address;
//             buyer = init_str.admin.address;
//             authorization_signature = ({
//                 signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
//                 message = ("54657374206d657373616765207465746574657465" : bytes);
//             }: authorization_signature);
//         } : buy_token)) 0tez
//     in

//     match result with
//         Success _gas -> failwith "Buy_fixed_price_token - Seller is buyer : This test should fail"
//     |   Fail (Rejected (err, _)) -> (
//             let () = assert_with_error ( Test.michelson_equal err (Test.eval "SELLER_NOT_AUTHORIZED") ) "Buy_fixed_price_token - Seller is buyer : Should not work if seller is buyer" in
//             "Passed"
//         )
//     |   Fail _ -> failwith "Internal test failure"    

// // Fail if wrong signature
// let test_buy_fixed_price_token_wrong_signature =
//     let _, contract_t_add, _, _ = get_fixed_price_contract (false) in
//     let init_str = Test.get_storage contract_t_add in
    
//     let no_admin_addr = Test.nth_bootstrap_account 1 in
//     let () = Test.set_source no_admin_addr in
    
//     let contract = Test.to_contract contract_t_add in

//     let result = Test.transfer_to_contract contract
//         (Buy_fixed_price_token ({
//             fa2_token = ({
//                 id = 0n;
//                 address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
//             } : fa2_base);
//             seller = init_str.admin.address;
//             buyer = no_admin_addr;
//             authorization_signature = ({
//                 signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
//                 message = ("54657374206d65737361676520746573742077726f6e67" : bytes);
//             }: authorization_signature);
//         })) 0tez
//     in

//     match result with
//         Success _gas -> failwith "Buy_fixed_price_token - Wrong signature : This test should fail"
//     |   Fail (Rejected (err, _)) -> (
//             let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "Buy_fixed_price_token - Wrong signature : Should not work if signature is not correct" in
//             "Passed"
//         )
//     |   Fail _ -> failwith "Internal test failure"    

// // Fail if signature already used
// let test_buy_fixed_price_token_signature_already_used =
//     let _, contract_t_add, _, _ = get_fixed_price_contract (true) in
//     let init_str = Test.get_storage contract_t_add in
    
//     let no_admin_addr = Test.nth_bootstrap_account 1 in
//     let () = Test.set_source no_admin_addr in
    
//     let contract = Test.to_contract contract_t_add in

//     let result = Test.transfer_to_contract contract
//         (Buy_fixed_price_token ({
//             fa2_token = ({
//                 id = 0n;
//                 address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
//             } : fa2_base);
//             seller = init_str.admin.address;
//             buyer = no_admin_addr;
//             authorization_signature = ({
//                 signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
//                 message = ("54657374206d657373616765207465746574657465" : bytes);
//             }: authorization_signature);
//         })) 100000mutez
//     in

//     match result with
//         Success _gas -> failwith "Buy_fixed_price_token - Signature already used : This test should fail"
//     |   Fail (Rejected (err, _)) -> (
//             let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNAUTHORIZED_USER") ) "Buy_fixed_price_token - Signature already used : Should not work if signature is not correct" in
//             "Passed"
//         )
//     |   Fail _ -> failwith "Internal test failure"    

// // Fail if wrong price specified
// let test_buy_fixed_price_token_wrong_price = 
//     let _, t_add,  fa2_add, _ = get_fixed_price_contract (false) in 
//     let init_str = Test.get_storage t_add in
    
//     let admin_addr = Test.nth_bootstrap_account 0 in
//     let () = Test.set_source admin_addr in
    
//     let contract = Test.to_contract t_add in

//     let _gas = Test.transfer_to_contract_exn contract
//         (Create_sales ({
//             authorization_signature = ({
//                 signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
//                 message = ("54657374206d657373616765207465746574657465" : bytes);
//             }: authorization_signature);
//             sale_infos = [({
//                 price = 150000mutez;
//                 buyer = None;
//                 fa2_token = {
//                     address = (fa2_add : address);
//                     id = 0n 
//                 };
//             } : sale_info );]
//         } : sale_configuration)) 0tez
//     in

//     let no_admin_addr = Test.nth_bootstrap_account 1 in
//     let () = Test.set_source no_admin_addr in

//     let result = Test.transfer_to_contract contract
//         (Buy_fixed_price_token ({
//             fa2_token = ({
//                 id = 0n;
//                 address = (fa2_add: address);
//             } : fa2_base);
//             seller = init_str.admin.address;
//             buyer = no_admin_addr;
//             authorization_signature = ({
//                 signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
//                 message = ("54657374206d6573736167652074657374207269676874" : bytes);
//             }: authorization_signature);
//         })) 100mutez
//     in

//     match result with
//         Success _gas -> failwith "Buy_fixed_price_token - Wrong price specified : This test should fail"
//     |   Fail (Rejected (err, _)) -> (
//             let () = assert_with_error ( Test.michelson_equal err (Test.eval "WRONG_PRICE_SPECIFIED") ) "Buy_fixed_price_token - Wrong price specified : Should not work if wrong price" in
//             "Passed"
//         )
//     |   Fail _ -> failwith "Internal test failure"    

// // Fail if not buyer
// let test_buy_fixed_price_token_not_buyer =
//     let _, t_add,  fa2_add, _ = get_fixed_price_contract (false) in 

//     let init_str = Test.get_storage t_add in

//     let admin_addr = Test.nth_bootstrap_account 0 in
//     let () = Test.set_source admin_addr in
    
//     let contract = Test.to_contract t_add in

//     let _gas = Test.transfer_to_contract_exn contract
//         (Create_sales ({
//             authorization_signature = ({
//                 signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
//                 message = ("54657374206d657373616765207465746574657465" : bytes);
//             }: authorization_signature);
//             sale_infos = [({
//                 price = 150000mutez;
//                 buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address );
//                 fa2_token = {
//                     address = (fa2_add : address);
//                     id = 0n 
//                 };
//             } : sale_info );]
//         } : sale_configuration)) 0tez
//     in

//     let no_admin_addr = Test.nth_bootstrap_account 1 in
//     let () = Test.set_source no_admin_addr in

//     let result = Test.transfer_to_contract contract
//         (Buy_fixed_price_token ({
//             fa2_token = ({
//                 id = 0n;
//                 address = (fa2_add : address);
//             } : fa2_base);
//             seller = init_str.admin.address;
//             buyer = no_admin_addr;
//             authorization_signature = ({
//                 signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
//                 message = ("54657374206d6573736167652074657374207269676874" : bytes);
//             }: authorization_signature);
      
//         })) 150000mutez
//     in

//     match result with
//         Success _gas -> failwith "Buy_fixed_price_token - Not specified buyer : This test should fail"
//     |   Fail (Rejected (err, _)) -> (
//             let () = assert_with_error ( Test.michelson_equal err (Test.eval "SENDER_NOT_AUTHORIZE_TO_BUY") ) "Buy_fixed_price_token - Not specified buyer : Should not work if signature is not correct" in
//             "Passed"
//         )
//     |   Fail _ -> failwith "Internal test failure"    


// // Success - verify fa2 transfer, fee & royalties
// let test_buy_fixed_price_token_success =
//     let _, t_add,  fa2_add, t_fa2_add = get_fixed_price_contract (false) in 
    
//     let init_str = Test.get_storage t_add in
    
//     let token_seller = Test.nth_bootstrap_account 3 in
//     let () = Test.set_source token_seller in
    
//     let contract = Test.to_contract t_add in

//     // Get balance of different actors of the sale to verify 
//     // that fees and royalties are sent correctly
//     let fee_account = Test.nth_bootstrap_account 2 in
//     let fee_account_bal = Test.get_balance fee_account in
    
//     let token_minter = Test.nth_bootstrap_account 4 in
//     let token_minter_bal = Test.get_balance token_minter in

//     let token_split = Test.nth_bootstrap_account 5 in
//     let token_split_bal = Test.get_balance token_split in

//     let _gas_creation_sale = Test.transfer_to_contract_exn contract
//         (Create_sales ({
//             authorization_signature = ({
//                 signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
//                 message = ("54657374206d657373616765207465746574657465" : bytes);
//             }: authorization_signature);
//             sale_infos = [({
//                 price = 213210368547757mutez;
//                 buyer = None;
//                 fa2_token = {
//                     address = (fa2_add : address);
//                     id = 0n 
//                 };
//             } : sale_info );]
//         } : sale_configuration)) 0tez
//     in

//     let buyer = Test.nth_bootstrap_account 1 in
//     let () = Test.set_source buyer in

//     let token_seller_bal = Test.get_balance token_seller in

//     let buyer_bal = Test.get_balance buyer in

//     let result = Test.transfer_to_contract contract
//         (Buy_fixed_price_token ({
//             fa2_token = ({
//                 id = 0n;
//                 address = (fa2_add : address);
//             } : fa2_base);
//             seller = token_seller;
//             buyer = buyer;
//             authorization_signature = ({
//                 signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
//                 message = ("54657374206d6573736167652074657374207269676874" : bytes);
//             }: authorization_signature);
      
//         })) 213210368547757mutez
//     in

//     // To check the result of the edition storage account
//     let edition_str = Test.get_storage t_fa2_add in
//     // To check the result of the fixed price storage account
//     let new_fp_str = Test.get_storage t_add in

//     match result with
//         Success _gas -> (
//             // Check that message has been correctly saved 
//             let () = match Big_map.find_opt ("54657374206d6573736167652074657374207269676874" : bytes) new_fp_str.admin.signed_message_used with
//                     Some _ -> unit
//                 |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Signed message not saved)" : unit)
//             in
//             // Check that sale is deleted from big map
//             let sale_key : fa2_base * address = (
//                 {
//                     address = (fa2_add : address);
//                     id = 0n
//                 },
//                 init_str.admin.address
//             ) in
//             let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
//                     Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
//                 |   None -> unit
//             in
            
//             // Check that fees been transfer to fee address
//             let new_fee_account_bal = Test.get_balance fee_account in
//             let () =    if new_fee_account_bal - fee_account_bal = Some (21321036854775mutez)
//                         then unit
//                         else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
//             in

//             // Check that 50% of the 15% royalties have been sent correctly to minter
//             let new_minter_account_bal = Test.get_balance token_minter in
//             let () =    if new_minter_account_bal - token_minter_bal = Some (15990777641081mutez)
//                         then unit
//                         else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
//             in

//             // Admin 50% of the 15% royalties here
//             let new_token_split_bal = Test.get_balance token_split in
//             let () =    if new_token_split_bal - token_split_bal = Some (15990777641081mutez)
//                         then unit
//                         else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
//             in

//             // Check that seller got the right amount
//             let new_token_seller_bal = Test.get_balance token_seller in
//             let () =    if new_token_seller_bal - token_seller_bal = Some (159907776410820mutez)
//                         then unit
//                         else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
//             in
                                    
//             // Check that buyer owns the token
//             let () = match Big_map.find_opt 0n edition_str.assets.ledger with
//                     Some add -> (
//                         if add = buyer
//                         then unit
//                         else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
//                     )
//                 |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
//             in
//             "Passed"
//         )   
//     |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"    
    
//     |   Fail _err -> failwith "Internal test failure"    

// Success - verify fa2 gallery transfer, fee & royalties
let test_buy_fixed_price_token_success_commission =
    let _, t_add, gallery, fa2_add, t_fa2_add = get_fixed_price_contract_gallery (false) in 
    
    let init_str = Test.get_storage t_add in
    
    let contract = Test.to_contract t_add in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 3 in
    
    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let gallery_bal = Test.get_balance gallery in

    let () = Test.set_source token_minter in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            sale_infos = [({
                price = 100tez;
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let token_minter_bal = Test.get_balance token_minter in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_minter;
            buyer = buyer;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: authorization_signature);
      
        })) 100tez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that message has been correctly saved 
            let () = match Big_map.find_opt ("54657374206d6573736167652074657374207269676874" : bytes) new_fp_str.admin.signed_message_used with
                    Some _ -> unit
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Signed message not saved)" : unit)
            in
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                init_str.admin.address
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (10tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (7.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            let new_gallery_account_bal = Test.get_balance gallery in
            let () =    if new_gallery_account_bal - gallery_bal = Some (50tez)
                        then unit   
                        else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to commission address)" : unit)
            in

            // Check that seller got the right amount
            let new_token_minter_bal = Test.get_balance token_minter in
            let () =    if new_token_minter_bal - token_minter_bal = Some (32.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in
                                    
            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = buyer
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"    
    |   Fail _err -> failwith "Internal test failure"        

let test_buy_fixed_price_token_success_secondary = 
    let _, t_add,  fa2_add, t_fa2_add = get_fixed_price_contract (false) in 
    
    let init_str = Test.get_storage t_add in
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract t_add in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            sale_infos = [({
                price = 213210368547757mutez;
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let _gas = Test.transfer_to_contract_exn contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_seller;
            buyer = buyer;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: authorization_signature);
      
        })) 213210368547757mutez
    in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    

    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigtcPETftjKnjZC7kXTi4FkTvu7HxFffuJvnMQBARqHN5vSdvURHcipybYM6j72e3N9eH69cnFjBAZA4qjaVfQ5mkCfdzF9L" : signature);
                message = ("726572657265" : bytes);
            }: authorization_signature);
            sale_infos = [({
                price = 213210368547757mutez;
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let () = Test.set_source token_seller in
    let token_seller_bal = Test.get_balance buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = buyer;
            buyer = token_seller;
            authorization_signature = ({
                signed = ("edsigte3DXyd46Qh8cqb2vCFSBZkyha9S4co9L2zKk4s3x8wMwR6TPUs7nLX2bYfzjDnzp5xaxuxg3cBJvnoMARAeyz8AkKJkLh" : signature);
                message = ("7265726572657265" : bytes);
            }: authorization_signature);
      
        })) 213210368547757mutez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that message has been correctly saved 
            let () = match Big_map.find_opt ("54657374206d6573736167652074657374207269676874" : bytes) new_fp_str.admin.signed_message_used with
                    Some _ -> unit
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Signed message not saved)" : unit)
            in
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                init_str.admin.address
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (7462362899171mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Check that 50% of the 15% royalties have been sent correctly to minter
            let new_minter_account_bal = Test.get_balance token_minter in
            let () =    if new_minter_account_bal - token_minter_bal = Some (15990777641081mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (15990777641081mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            // Check that seller got the right amount
            let new_token_seller_bal = Test.get_balance buyer in
            let () =    if new_token_seller_bal - token_seller_bal = Some (173766450366424mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in

            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = token_seller
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"
    
    |   Fail _ -> failwith "Internal test failure"    


// Fail if seller not owner of token or token not in sale (same case)
let test_buy_fixed_price_token_fail_if_wrong_seller =
    let _, t_add,  fa2_add, _ = get_fixed_price_contract (false) in 

    let init_str = Test.get_storage t_add in
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract t_add in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = init_str.admin.address;
            buyer = buyer;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: authorization_signature);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is not for_sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_IN_SALE") ) "Buy_fixed_price_token - Seller is not for_sale owner : Should not work if seller is not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


let test_buy_fixed_price_token_success_secondary_commission = 
    let _, t_add, gallery, fa2_add, t_fa2_add = get_fixed_price_contract_gallery (false) in 
    
    let init_str = Test.get_storage t_add in
    
    let token_minter = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_minter in
    
    let contract = Test.to_contract t_add in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigu4PZariPHMdLN4j7EDpTzUwW63ipuE7xxpKqjFMKQQ7vMg6gAtiQHCfTDK9pPMP9nv11Mwa1VmcspBv4ugLc5Lwx3CZdBg" : signature);
                message = ("54657374206d657373616765207465746574657465" : bytes);
            }: authorization_signature);
            sale_infos = [({
                price = 213210368547757mutez;
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in
    
    let _gas = Test.transfer_to_contract_exn contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_minter;
            buyer = buyer;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: authorization_signature);
      
        })) 213210368547757mutez
    in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    

    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let gallery_bal = Test.get_balance gallery in

    let second_buyer = Test.nth_bootstrap_account 9 in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            authorization_signature = ({
                signed = ("edsigtcPETftjKnjZC7kXTi4FkTvu7HxFffuJvnMQBARqHN5vSdvURHcipybYM6j72e3N9eH69cnFjBAZA4qjaVfQ5mkCfdzF9L" : signature);
                message = ("726572657265" : bytes);
            }: authorization_signature);
            sale_infos = [({
                price = 100tez;
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let () = Test.set_source second_buyer in
    let token_seller_bal = Test.get_balance buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = buyer;
            buyer = second_buyer;
            authorization_signature = ({
                signed = ("edsigte3DXyd46Qh8cqb2vCFSBZkyha9S4co9L2zKk4s3x8wMwR6TPUs7nLX2bYfzjDnzp5xaxuxg3cBJvnoMARAeyz8AkKJkLh" : signature);
                message = ("7265726572657265" : bytes);
            }: authorization_signature);
      
        })) 100tez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that message has been correctly saved 
            let () = match Big_map.find_opt ("54657374206d6573736167652074657374207269676874" : bytes) new_fp_str.admin.signed_message_used with
                    Some _ -> unit
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Signed message not saved)" : unit)
            in
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                init_str.admin.address
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (3.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Check that 50% of the 15% royalties have been sent correctly to minter
            let new_minter_account_bal = Test.get_balance token_minter in
            let () =    if new_minter_account_bal - token_minter_bal = Some (7.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (7.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            let new_gallery_bal = Test.get_balance gallery in
            let () =    if new_gallery_bal = gallery_bal
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Gallery should not get any commission on the secondary market)" : unit)
            in

            // Check that seller got the right amount
            let new_token_seller_bal = Test.get_balance buyer in
            let () =    if new_token_seller_bal - token_seller_bal = Some (81.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in

            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = second_buyer
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"
    
    |   Fail _ -> failwith "Internal test failure"    


// Fail if seller not owner of token or token not in sale (same case)
let test_buy_fixed_price_token_fail_if_wrong_seller =
    let _, t_add,  fa2_add, _ = get_fixed_price_contract (false) in 

    let init_str = Test.get_storage t_add in
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract t_add in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = init_str.admin.address;
            buyer = buyer;
            authorization_signature = ({
                signed = ("edsigu36wtky5nKCx6u4YWWbau68sQ9JSEr6Fb3f5CiwU5QSdLsRB2H6shbsZHo9EinNoHxq6f96Sm48UnfEfQxwVJCWy3Qodgz" : signature);
                message = ("54657374206d6573736167652074657374207269676874" : bytes);
            }: authorization_signature);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is not for_sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_IN_SALE") ) "Buy_fixed_price_token - Seller is not for_sale owner : Should not work if seller is not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
