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
        { DROP 2 ; NONE (pair nat (map string bytes)) }
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
            { DROP 3 ; NONE (pair nat (map string bytes)) }
            { DUP 4 ;
              CDR ;
              CAR ;
              CDR ;
              PUSH string "symbol" ;
              GET ;
              IF_NONE
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
                  PAIR ;
                  SOME }
                { SWAP ;
                  DUP ;
                  DUG 2 ;
                  GET 3 ;
                  PUSH nat 1 ;
                  DIG 6 ;
                  CDR ;
                  CAR ;
                  CAR ;
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
      IF_NONE { NONE (list (pair address nat)) } { GET 10 ; SOME } }`
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
        { NONE (pair nat (list (pair address nat))) }
        { DUP ; GET 10 ; SWAP ; GET 9 ; PAIR ; SOME } }`
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
      IF_NONE { NONE nat } { GET 9 ; SOME } }`
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
      IF_NONE { NONE address } { CAR ; SOME } }`
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
        { DROP ; NONE bool }
        { SWAP ;
          CAR ;
          SWAP ;
          CAR ;
          COMPARE ;
          EQ ;
          IF { PUSH bool True ; SOME } { PUSH bool False ; SOME } } }`
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
        { NONE bool }
        { PUSH nat 1 ;
          SWAP ;
          GET 5 ;
          COMPARE ;
          GT ;
          IF { PUSH bool False ; SOME } { PUSH bool True ; SOME } } }`
}

