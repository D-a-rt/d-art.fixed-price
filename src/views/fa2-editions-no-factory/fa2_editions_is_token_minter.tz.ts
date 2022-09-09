export type IsTokenMinterViewNoFactoryCodeType = { __type: 'IsTokenMinterViewNoFactoryCodeType'; code: string; };
export default {
  __type: 'IsTokenMinterViewNoFactoryCodeType', code: `
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
        IF { PUSH bool True } { PUSH bool False } } }
  `
} as IsTokenMinterViewNoFactoryCodeType