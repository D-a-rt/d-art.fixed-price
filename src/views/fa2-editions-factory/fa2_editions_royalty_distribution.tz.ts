export type RoyaltyDistributionFactoryViewCodeType = { __type: 'RoyaltyDistributionFactoryViewCodeType'; code: string; };
export default {
  __type: 'RoyaltyDistributionFactoryViewCodeType', code: `
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
    DUP ;
    DUG 2 ;
    CAR ;
    CDR ;
    CAR ;
    SWAP ;
    GET ;
    IF_NONE
      { DROP ; PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
      { DUP ; GET 6 ; SWAP ; GET 5 ; PAIR ; SWAP ; CAR ; CAR ; CAR ; CAR ; PAIR } }
  `
} as RoyaltyDistributionFactoryViewCodeType