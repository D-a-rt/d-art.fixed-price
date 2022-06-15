# d-art.contracts

#### Introduction:

This set of contracts has been developped in order to perform fixed price sale and drop on-chain.

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

Available contract title: ***fixed-price, fa2-editions***
Note: these commands has been tested with the version 0.43 of ligo.
```
$ d-art.contracts test-contract -t <contract-title>
    (Run the ligo test on the contract corresponding to the title - if no title specified run the test for the the two contracts)

$ d-art.contracts compile-contract -t <contract-name>
    (Compile the contract corresponding to the title - if no title specified compile the two contracts)

$ d-art.contracts deploy-contract -t <contract-name>
    (Deploy the contract corresponding to the title - if no title specified deploy the two contracts)

$ d-art.contracts contract-size -t <contract-name>
    (Give the size of the contracts to deploy - if not title specified give the size of each contract)

$ d-art.fixed-price gen-keypair
    (Generate public/private key pair in order to create signed message)

$ d-art.fixed-price sign-payload
    (Sign a random payload and give back message as bytes + signed message )

$ d-art.fixed-price deploy-contract
    (Deploy the contract previously compiled in the project)

$ d-art.fixed-price -v
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

-[Fixed Price](./ligo/d-art.fixed-price)
-[FA2 Editions](./ligo/d-art.fa2-editions)

### Tests 

-[Fixed Price](./ligo/test/d-art.fixed-price)
-[FA2 Editions](./ligo/test/d-art.fa2-editions)


### Contract deployed:

#### FA2 Edition:
    
    Ithaca : - 
    Jakarta : -


#### Fixed price :
    
    Ithaca : - 
    Jakarta : -