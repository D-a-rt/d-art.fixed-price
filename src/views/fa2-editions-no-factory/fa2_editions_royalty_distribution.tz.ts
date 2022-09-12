export type RoyaltyDistributionNoFactoryViewCodeType = { __type: 'RoyaltyDistributionNoFactoryViewCodeType'; code: string; };
export default {
  __type: 'RoyaltyDistributionNoFactoryViewCodeType', code: `
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
} as RoyaltyDistributionNoFactoryViewCodeType