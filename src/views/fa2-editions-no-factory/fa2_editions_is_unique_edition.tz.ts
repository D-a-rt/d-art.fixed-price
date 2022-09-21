export type IsUniqueEditionViewCodeType = { __type: 'IsUniqueEditionViewCodeType'; code: string; };
export default {
  __type: 'IsUniqueEditionViewCodeType', code: `
  { UNPAIR ;
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
        IF { PUSH bool False } { PUSH bool True } } }
  `
} as IsUniqueEditionViewCodeType