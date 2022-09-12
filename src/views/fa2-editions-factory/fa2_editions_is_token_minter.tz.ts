export type IsTokenMinterViewFactoryCodeType = { __type: 'IsTokenMinterViewFactoryCodeType'; code: string; };
export default {
  __type: 'IsTokenMinterViewFactoryCodeType', code: `
  { UNPAIR ;
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
        IF { PUSH bool True } { PUSH bool False } } }
  `
} as IsTokenMinterViewFactoryCodeType