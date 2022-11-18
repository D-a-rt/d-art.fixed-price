export const TokenMetadataViewLegacy = {
    code : `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CAR ;
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
            CDR ;
            CAR ;
            CAR ;
            SWAP ;
            DUP ;
            DUG 2 ;
            EDIV ;
            IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
            CAR ;
            DUP 3 ;
            CAR ;
            CDR ;
            CDR ;
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
                CDR ;
                CAR ;
                CAR ;
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
                GET 7 ;
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

export const RoyaltyDistributionViewLegacy ={
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CDR ;
        CAR ;
        CAR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        GET ;
        IF_NONE
          { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { DUP ; GET 10 ; SWAP ; DUP ; DUG 2 ; GET 9 ; PAIR ; SWAP ; CAR ; PAIR } }`
}

export const SplitsViewLegacy = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CDR ;
        CAR ;
        CAR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        GET ;
        IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { GET 10 } }`
}

export const RoyaltySplitsViewLegacy = {
    code : `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CDR ;
        CAR ;
        CAR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        GET ;
        IF_NONE
          { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { DUP ; GET 10 ; SWAP ; GET 9 ; PAIR } }`
}

export const RoyaltyViewLegacy = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CDR ;
        CAR ;
        CAR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        GET ;
        IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { GET 9 } }`
}

export const MinterViewLegacy = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CDR ;
        CAR ;
        CAR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CDR ;
        SWAP ;
        GET ;
        IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { CAR } }`
}

export const IsTokenMinterViewLegacy = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CDR ;
        CAR ;
        CAR ;
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
        CDR ;
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

export const IsUniqueEditionViewLegacy = {
    code: `{ UNPAIR ;
        SWAP ;
        DUP ;
        DUG 2 ;
        CDR ;
        CAR ;
        CAR ;
        SWAP ;
        EDIV ;
        IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
        CAR ;
        SWAP ;
        CAR ;
        CDR ;
        CDR ;
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

