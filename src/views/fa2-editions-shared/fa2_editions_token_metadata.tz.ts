export type EditionsTokenMetadataViewCodeType = { __type: 'EditionsTokenMetadataViewCodeType'; code: string; };
export default {
  __type: 'EditionsTokenMetadataViewCodeType', code: `
  { UNPAIR ;
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
          { GET 3 ;
            PUSH nat 1 ;
            DIG 4 ;
            CAR ;
            CDR ;
            CDR ;
            DIG 3 ;
            MUL ;
            DUP 4 ;
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
            PAIR } } }
  `
} as EditionsTokenMetadataViewCodeType