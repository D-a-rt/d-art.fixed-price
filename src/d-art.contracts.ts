#!/usr/bin/env node

const program = require('commander');
import * as ver from './ver';
import * as contract from './contract';
import * as helper from './helper';


program
    .command('test-contract')
    .option('-t, --title <title>', 'Title of the contract to test: fixed-price, fa2-editions')
    .action((title: string) => {
        contract.testContracts(title)
    })

program
    .command('compile-contract')
    .option('-t, --title <title>', 'Title of the contract to compile: fixed-price, fa2-editions, fa2-editions-factory, serie-factory')
    .action((title: string) => {
        contract.compileContracts(title)
    })

program
    .command('deploy-contract')
    .option('-t, --title <title>', 'Title of the contract to measure: fixed-price, fa2-editions, serie-factory')
    .action((title: string) => {
        contract.deployContracts(title)
    })

program
    .command('contract-size')
    .option('-t, --title <title>', 'Title of the contract to measure: fixed-price, fa2-editions, fa2-editions-factory, serie-factory')
    .action((title: string) => {
        contract.calculateSize(title)
    })

program
    .command('gen-keypair')
    .option('-s, --seed <seed>', 'Seed phrase to generate keys')
    .action((seed: string) => {
        helper.generateKeyPair(seed)
    })

program
    .command('sign-payload')
    .option('-m, --message <payload>', 'Payload to encode')
    .action((option: any) => {
        helper.encodePayload(option.message)
    })

program
    .option('-v', 'show version', ver, '')
    .action(ver.showVersion);

program.parse(process.argv)