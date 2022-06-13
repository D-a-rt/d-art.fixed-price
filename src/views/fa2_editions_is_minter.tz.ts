export type IsMinterViewCodeType = { __type: 'IsMinterViewCodeType'; code: string; };
export default {
  __type: 'IsMinterViewCodeType', code: `
  { UNPAIR ;
    SWAP ;
    CAR ;
    CAR ;
    CAR ;
    CAR ;
    CDR ;
    SWAP ;
    GET ;
    IF_NONE { PUSH bool False } { DROP ; PUSH bool True } }
  `
} as IsMinterViewCodeType