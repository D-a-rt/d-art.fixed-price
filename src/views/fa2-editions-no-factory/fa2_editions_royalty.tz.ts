
export type RoyaltyViewCodeType = { __type: 'RoyaltyViewCodeType'; code: string; };
export default {
  __type: 'RoyaltyViewCodeType', code: `
  { UNPAIR ;
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
    IF_NONE { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH } { GET 7 } }
  `
} as RoyaltyViewCodeType;
;
