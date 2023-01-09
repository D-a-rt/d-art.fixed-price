export const TokenMetadataViewSpace = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CAR ;
        CDR ;
        CAR ;
        CAR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        GET ;
        IF_NONE
          { DROP 2 ; PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { DROP ;
            SWAP ;
            DUP ;
            DUG 2 ;
            CAR ;
            CDR ;
            CDR ;
            SWAP ;
            DUP ;
            DUG 2 ;
            EDIV ;
            IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
            CAR ;
            DUP 3 ;
            CAR ;
            CDR ;
            CAR ;
            SWAP ;
            DUP ;
            DUG 2 ;
            GET ;
            IF_NONE
              { DROP 3 ; PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
              { DUP ;
                GET 3 ;
                PUSH nat 1 ;
                DIG 5 ;
                CAR ;
                CDR ;
                CDR ;
                DIG 4 ;
                MUL ;
                DUP 5 ;
                SUB ;
                ADD ;
                PACK ;
                PUSH string "edition_number" ;
                PAIR 3 ;
                UNPAIR 3 ;
                SWAP ;
                SOME ;
                SWAP ;
                UPDATE ;
                SWAP ;
                GET 9 ;
                CDR ;
                PUSH string "license" ;
                PAIR 3 ;
                UNPAIR 3 ;
                SWAP ;
                SOME ;
                SWAP ;
                UPDATE ;
                SWAP ;
                PAIR } } }`
}

export const RoyaltyDistributionViewSpace = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE
          { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { DUP ; GET 11 ; SWAP ; DUP ; DUG 2 ; GET 7 ; PAIR ; SWAP ; CAR ; PAIR } }`
}

export const SplitsViewSpace = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { GET 11 } }`
}

export const RoyaltySplitsViewSpace = {
    code : `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE
          { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { DUP ; GET 11 ; SWAP ; GET 7 ; PAIR } }`
}

export const RoyaltyViewSpace = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { GET 7 } }`
}

export const MinterViewSpace = {
    code : `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { CAR } }`
}

export const IsTokenMinterViewSpace = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CDR ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        DIG 2 ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE
          { DROP ; PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { SWAP ;
            CAR ;
            SWAP ;
            CAR ;
            COMPARE ;
            EQ ;
            IF { PUSH bool True } { PUSH bool False } } }`
}

export const IsUniqueEditionSpace = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE
          { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { PUSH nat 1 ;
            SWAP ;
            GET 5 ;
            COMPARE ;
            GT ;
            IF { PUSH bool False } { PUSH bool True } } }`
}

export const CommissionSplitsViewSpace = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE
          { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { DUP ; GET 14 ; SWAP ; GET 13 ; PAIR } }`
}