type admin_entrypoints =
    | Send_invitations of (fa2_base * minter) list
    | Remove_invitations of (fa2_base * minter) list
    | Set_start_date of timestamp
    | Set_end_date of timestamp
    | Set_commission of nat
    | Set_commission_split of split list
    | Set_grace_period of nat
    | List_synthetic_assets of sale_configuration
    | Edit_listings of sale_configuration
    | Start_grace_period
    | Reset_exhibition

[@inline]
let fail_if_not_admin (storage : storage) : unit = if Tezos.get_sender() <> storage.admin_str.admin then failwith "NOT_AN_ADMIN"
