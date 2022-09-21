[@inline]
let assert_msg (condition, msg : bool * string ) : unit = if (not condition) then failwith(msg) else unit

type storage = 
[@layout:comb]
{
    admins: (address, unit) big_map;
    pending_admin: address;
}

type withdrawal_param = 
[@layout:comb] 
{
    receiver: address;
    amount: tez
}

type art_treasury = 
    |   Send_admin_invitation of address
    |   Revoke_admin_invitation of unit
    |   Accept_admin_invitation of boolean
    |   Withdrawal of withdrawal_param

let fail_if_not_admin