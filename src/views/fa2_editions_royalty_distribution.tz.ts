export type RoyaltyDistributionViewCodeType = { __type: 'RoyaltyDistributionViewCodeType'; code: string; };
export default {
  __type: 'RoyaltyDistributionViewCodeType', code: `
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
    IF_NONE
      { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
      { DUP ; GET 8 ; SWAP ; DUP ; DUG 2 ; GET 7 ; PAIR ; SWAP ; CAR ; PAIR } }
  `
} as RoyaltyDistributionViewCodeType