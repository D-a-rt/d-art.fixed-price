# there.contracts

#### Link to Audit:

The audit of the smart-contracts is available following this [link](https://github.com/InferenceAG/ReportPublications/blob/master/Inference%20AG%20-%20THERE%20-%20curated%20art%20platform%20smart%20contracts%20-%20v1.0.pdf)


#### Introduction:

This set of contracts contain 5 different types of contract: fa2-editions (three variants), fixed-price and serie-factory, space-factory and permission-manager.

#### Prerequisites

- docker installed
- node installed
- npm installed

#### Install the CLI (TypeScript):

To install all the dependencies of the project please run:

```
$ cd /there.contracts
$ npm install
$ npm run-script build  ( || npm run-script build:watch . )
$ npm install -g
```

The different available commands are:

`contract-title`: ***fixed-price | fa2-editions | fa2-editions-serie | fa2-editions-space | serie-factory | space-factory | permission-manager*** 

`contract-deploy-title` : ***fixed-price | fa2-editions | serie-factory | space-factory | permission-manager*** 

Note: these commands has been tested with the version 0.43 of ligo.
```

$ there.contracts test-contract -t <contract-title>
    (Run the ligo test on the contract corresponding to the title - if no title specified run the test for the the two contracts)

$ there.contracts compile-contract -t <contract-title>
    (Compile the contract corresponding to the title - if no title specified compile the two contracts)

$ there.contracts deploy-contract -t <contract-deploy-title> 
    (Deploy the contract corresponding to the title - if no title specified deploy the two contracts)

$ there.contracts contract-size -t <contract-title>
    (Give the size of the contracts to deploy - if not title specified give the size of each contract)

$ there.contracts gen-keypair
    (Generate public/private key pair in order to create signed message)

$ there.contracts sign-payload
    (Sign a random payload and give back message as bytes + signed message )

$ there.contracts deploy-contract
    (Deploy the contract previously compiled in the project)

$ there.contracts -v
    (Get the current version of the project)
```

In case you would like to run each test separately:

```
$ alias ligo="docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.43.0" 
$ cd there.contracts

$ ligo run test ligo/test/there.fixed-price/fixed_price_main_buy_drop.test.mligo 
  (or any othe test file)
```

## Contracts

- [Fixed Price](./ligo/there.fixed-price)
- [FA2 Editions](./ligo/there.fa2-editions)
- [Serie Factory](./ligo/there.art-factories/serie_factory.mligo)
- [Space Factory](./ligo/there.art-factories/space_factory.mligo)
- [Permission manager](./ligo/there.permission-manager)

### Tests 

- [Fixed Price](./ligo/test/there.fixed-price)
- [FA2 Editions](./ligo/test/there.fa2-editions)
- [Serie Factory](./ligo/test/there.art-factories/serie_factory_main.test.mligo)
- [Space Factory](./ligo/test/there.art-factories/space_factory_main.test.mligo)
- [Permission manager](./ligo/test/there.permission-manager)


