#import "../../there.fa2-editions/interface.mligo" "FA2_I"

type storage = nat list

let main ((responses, _strg) : ((FA2_I.balance_of_response list) * storage)) : ((operation list) * storage) = 
    let balances = List.map ( fun(r : FA2_I.balance_of_response) -> r.balance) responses in
    ([] : operation list), balances
