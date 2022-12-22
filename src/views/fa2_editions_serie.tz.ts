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
                  PAIR }
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
                  PAIR } } } }`
}

export const RoyaltyDistributionViewSerie = {
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
        DUP ;
        DUG 2 ;
        CAR ;
        CDR ;
        CAR ;
        SWAP ;
        GET ;
        IF_NONE
          { DROP ; PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { DUP ; GET 8 ; SWAP ; GET 7 ; PAIR ; SWAP ; CAR ; CAR ; CAR ; CAR ; PAIR } }`
}

export const SplitsViewRoyalty = {
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
        IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { GET 8 } }`
}

export const RoyaltySplitsViewSerie = {
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
          { DUP ; GET 8 ; SWAP ; GET 7 ; PAIR } }`
}

export const RoyaltyViewSerie = {
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
        IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { GET 7 } } ;
 view "minter" nat address { CDR ; CAR ; CAR ; CAR ; CAR }`
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
          { DROP 2 ; PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { DROP ;
            CAR ;
            SWAP ;
            CAR ;
            CAR ;
            CAR ;
            CAR ;
            COMPARE ;
            EQ ;
            IF { PUSH bool True } { PUSH bool False } } }`
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
          { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
          { PUSH nat 1 ;
            SWAP ;
            GET 3 ;
            COMPARE ;
            GT ;
            IF { PUSH bool False } { PUSH bool True } } }`
}
