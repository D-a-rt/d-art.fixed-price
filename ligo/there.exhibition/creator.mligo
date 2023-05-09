type creator_entrypoints =
    | Accept_invitations of (fa2_base * accept) list
    | Accept_listings of (nat * accept) list
    | Claim_artworks of nat list

