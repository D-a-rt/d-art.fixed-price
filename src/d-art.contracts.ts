#!/usr/bin/env node

const program = require('commander');
import * as ver from './ver';
import * as contract from './contract';
import * as helper from './helper';


program
    .command('test-contract')
    .option('-t, --title <title>', 'Title of the contract to test: fixed-price, fa2-editions, fa2-editions-serie, fa2-editions-gallery, serie-factory, gallery-factory, permission-manager')
    .action((title: string) => {
        contract.testContracts(title)
    })

program
    .command('compile-contract')
    .option('-t, --title <title>', 'Title of the contract to compile: fixed-price, fa2-editions, fa2-editions-serie, fa2-editions-gallery, serie-factory, gallery-factory, permission-manager')
    .action((title: string) => {
        contract.contracts(title, contract.ContractAction.COMPILE)
    })

program
    .command('deploy-contract')
    .option('-t, --title <title>', 'Title of the contract to measure: fixed-price, fa2-editions, serie-factory')
    .option('-pm, --permission-manager <permissionManager>', 'Any permission manager contract already deployed')
    .action((title: string, permissionManager: string) => {
        contract.deployContracts(title, permissionManager)
    })

program
    .command('contract-size')
    .option('-t, --title <title>', 'Title of the contract to measure: fixed-price, fa2-editions, fa2-editions-serie, fa2-editions-gallery, serie-factory, gallery-factory, permission-manager')
    .action((title: string) => {
        contract.contracts(title, contract.ContractAction.SIZE)
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
    . command('upload_metadata')
    .action((option: any) => {
        contract.uploadContractMetadata()
    })

program
    .option('-v', 'show version', ver, '')
    .action(ver.showVersion);

program.parse(process.argv)