export const TokenMetadataViewSerie = {
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
          { DROP 2 ; NONE (pair nat (map string bytes)) }
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
              { DROP 3 ; NONE (pair nat (map string bytes)) }
              { DUP 4 ;
                CDR ;
                CAR ;
                PUSH string "symbol" ;
                GET ;
                IF_NONE
                  { DUP ;
                    CAR ;
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
                    GET 5 ;
                    CDR ;
                    PUSH string "license" ;
                    PAIR 3 ;
                    UNPAIR 3 ;
                    SWAP ;
                    SOME ;
                    SWAP ;
                    UPDATE ;
                    SWAP ;
                    PAIR ;
                    SOME }
                  { SWAP ;
                    DUP ;
                    DUG 2 ;
                    CAR ;
                    PUSH nat 1 ;
                    DIG 6 ;
                    CAR ;
                    CDR ;
                    CDR ;
                    DIG 5 ;
                    MUL ;
                    DUP 6 ;
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
                    DIG 2 ;
                    GET 5 ;
                    CDR ;
                    PUSH string "license" ;
                    PAIR 3 ;
                    UNPAIR 3 ;
                    SWAP ;
                    SOME ;
                    SWAP ;
                    UPDATE ;
                    SWAP ;
                    PUSH string "symbol" ;
                    PAIR 3 ;
                    UNPAIR 3 ;
                    SWAP ;
                    SOME ;
                    SWAP ;
                    UPDATE ;
                    SWAP ;
                    PAIR ;
                    SOME } } } }`
}

export const RoyaltyDistributionViewSerie = {
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
          { NONE (pair address (pair nat (list (pair address nat)))) }
          { DUP ;
            GET 10 ;
            SWAP ;
            DUP ;
            DUG 2 ;
            GET 9 ;
            PAIR ;
            SWAP ;
            CAR ;
            PAIR ;
            SOME } }`
}

export const SplitsViewRoyalty = {
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
        IF_NONE { NONE (list (pair address nat)) } { GET 10 ; SOME } }`
}

export const RoyaltySplitsViewSerie = {
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
          { NONE (pair nat (list (pair address nat))) }
          { DUP ; GET 10 ; SWAP ; GET 9 ; PAIR ; SOME } }`
}

export const RoyaltyViewSerie = {
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
        IF_NONE { NONE nat } { GET 9 ; SOME } }`
}

export const MinterViewSerie = {
    code: `{ CDR ; CAR ; CAR ; CAR ; CAR }`
}

export const IsTokenMinterViewSerie = {
    code : `{ UNPAIR ;
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
      DUP 3 ;
      CAR ;
      CDR ;
      CAR ;
      SWAP ;
      GET ;
      IF_NONE
        { DROP 2 ; NONE bool }
        { DROP ;
          CAR ;
          SWAP ;
          CAR ;
          CAR ;
          CAR ;
          CAR ;
          COMPARE ;
          EQ ;
          IF { PUSH bool True ; SOME } { PUSH bool False ; SOME } } }`
}

export const IsUniqueEditionViewSerie = {
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
        { NONE bool }
        { PUSH nat 1 ;
          SWAP ;
          GET 3 ;
          COMPARE ;
          GT ;
          IF { PUSH bool False ; SOME } { PUSH bool True ; SOME } } }`
}
