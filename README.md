# d-art.contracts

#### Introduction:

This set of contracts contain three different types of contract: fa2-editions (two variants), fixed-price and fa2-editions-factory (will call it serie-factory).

#### Prerequisites

- docker installed
- node installed
- npm installed

#### Install the CLI (TypeScript):

To install all the dependencies of the project please run:

```
$ cd /d-art.contracts
$ npm install
$ npm run-script build  ( || npm run-script build:watch . )
$ npm install -g
```

The different available commands are:

Available contract title: ***fixed-price | fa2-editions | fa2-editions-factory | serie-factory*** 

Note: these commands has been tested with the version 0.43 of ligo.
```

$ d-art.contracts test-contract -t <contract-title>
    (Run the ligo test on the contract corresponding to the title - if no title specified run the test for the the two contracts)

$ d-art.contracts compile-contract -t <contract-title>
    (Compile the contract corresponding to the title - if no title specified compile the two contracts)

$ d-art.contracts deploy-contract -t <contract-title>
    (Deploy the contract corresponding to the title - if no title specified deploy the two contracts)

$ d-art.contracts contract-size -t <contract-title>
    (Give the size of the contracts to deploy - if not title specified give the size of each contract)

$ d-art.contracts gen-keypair
    (Generate public/private key pair in order to create signed message)

$ d-art.contracts sign-payload
    (Sign a random payload and give back message as bytes + signed message )

$ d-art.contracts deploy-contract
    (Deploy the contract previously compiled in the project)

$ d-art.contracts -v
    (Get the current version of the project)
```

In case you would like to run each test separately:

```
$ alias ligo="docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:0.43.0" 
$ cd d-art.contracts

$ ligo run test ligo/test/d-art.fixed-price/fixed_price_main_buy_drop.test.mligo 
  (or any othe test file)
```

## Contracts

- [Fixed Price](./ligo/d-art.fixed-price)
- [FA2 Editions](./ligo/d-art.fa2-editions)
- [Serie Factory](./ligo/d-art.serie-factory)

### Tests 

- [Fixed Price](./ligo/test/d-art.fixed-price)
- [FA2 Editions](./ligo/test/d-art.fa2-editions)
- [Serie Factory](./ligo/test/d-art.serie-factory)


### Contract deployed:

#### FA2 Edition:
    
    Jakarta TestNet: -
    Mainnet : - 

#### Serie Factory :
    
    Jakarta TestNet: -
    Mainnet : - 

#### Fixed price :
    
    Jakarta TestNet: -
    Mainnet : - 