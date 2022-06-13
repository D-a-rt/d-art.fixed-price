require('dotenv').config()
import * as fs from 'fs';
import * as path from 'path';
import * as kleur from 'kleur';
import * as child from 'child_process';

import { loadFile } from './helper';
import { char2Bytes } from '@taquito/tzip16';
import { Parser} from '@taquito/michel-codec';
import { InMemorySigner } from '@taquito/signer';
import { MichelsonMap, TezosToolkit } from '@taquito/taquito';

enum ContractAction {
    COMPILE = "compile contract",
    SIZE = "info measure-contract"
}

async function contractAction (contractName: string, action: ContractAction, pathString: string, mainFunction: string, compilePath?: string) : Promise<void> {
    await new Promise<void>((resolve, reject) =>
        child.exec(
            path.join(__dirname, `../ligo/exec_ligo ${action} ` + path.join(__dirname, `../ligo/${pathString}`) + ` -e ${mainFunction}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to compile the contract.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    // Write json contract into json file
                    if (action === ContractAction.COMPILE) {
                        console.log(kleur.green(`Compiled ${contractName} contract succesfully at: `))
                        console.log('  ' + path.join(__dirname, `../ligo/${compilePath}`))
                        fs.writeFileSync(path.join(__dirname, `../ligo/${compilePath}`), stdout)
                    }

                    if (action === ContractAction.SIZE) {
                        console.log(kleur.green(`Contract ${contractName} size: ${stdout}`))
                    }
                    resolve();
                }
            }
        )
    );
}

// -- Compile contracts --

export async function compileContracts(param: any): Promise<void> {
    switch (param.title) {
        case "fixed-price":
            contractAction("Fixed-price", ContractAction.COMPILE, "d-art.fixed-price/fixed_price_main.mligo", "fixed_price_tez_main", "d-art.fixed-price/compile/fixed_price_main.tz")
            break;
        case "fa2-editions":
            contractAction("Fa2 editions", ContractAction.COMPILE, "d-art.fa2-editions/views.mligo", "editions_main --views 'token_metadata, splits, royalty_splits, royalty, minter'", "d-art.fa2-editions/compile/multi_nft_token_editions.tz")
            break;
        default:
            contractAction("Fixed-price", ContractAction.COMPILE, "d-art.fixed-price/fixed_price_main.mligo", "fixed_price_tez_main", "d-art.fixed-price/compile/fixed_price_main.tz")
            contractAction("Fa2 editions", ContractAction.COMPILE, "d-art.fa2-editions/views.mligo", "editions_main --views 'token_metadata, splits, royalty_splits, royalty, minter'", "d-art.fa2-editions/compile/multi_nft_token_editions.tz")
            break;
    }
}

export async function calculateSize(param: any): Promise<void> {
    switch (param.title) {
        case "fixed-price":
            contractAction("Fixed-price", ContractAction.SIZE, "d-art.fixed-price/fixed_price_main.mligo", "fixed_price_tez_main")
            break;
        case "fa2-editions":
            contractAction("Fa2 editions", ContractAction.SIZE, "d-art.fa2-editions/views.mligo", "editions_main --views 'token_metadata, splits, royalty_splits, royalty, minter'")
            break;
        default:
            contractAction("Fixed-price", ContractAction.SIZE, "d-art.fixed-price/fixed_price_main.mligo", "fixed_price_tez_main")
            contractAction("Fa2 editions", ContractAction.SIZE, "d-art.fa2-editions/views.mligo", "editions_main --views 'token_metadata, splits, royalty_splits, royalty, minter'")
            break;
    }
}

// -- Deploy contracts --

export async function deployFixedPriceContract(): Promise<void> {
    const code = await loadFile(path.join(__dirname, '../ligo/d-art.fixed-price/compile/fixed_price_main.tz'))

    const originateParam = {
        code: code,
        storage: {
            admin: {
                address: process.env.ADMIN_PUBLIC_KEY_HASH,
                pb_key: process.env.SIGNER_PUBLIC_KEY,
                signed_message_used: new MichelsonMap(),
                contract_will_update: false
            },
            for_sale: MichelsonMap.fromLiteral({}),
            authorized_drops_seller: MichelsonMap.fromLiteral({}),
            drops: MichelsonMap.fromLiteral({}),
            fa2_dropped: MichelsonMap.fromLiteral({}),
            fee: {
                address: process.env.ADMIN_PUBLIC_KEY_HASH,
                percent: 10,
            }
        }
    }

    try {
        const toolkit = await new TezosToolkit('https://ithacanet.ecadinfra.com');

        toolkit.setProvider({ signer: await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) });

        const originationOp = await toolkit.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Fixed price sale (tez) origination error ${jsonError}`));
    }
}

export async function deployEditionContract(): Promise<void> {
    const code = await loadFile(path.join(__dirname, '../ligo/d-art.fa2-editions/compile/multi_nft_token_editions.tz'))

    // const p = new Parser();
    // const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(EditionsMetadata.code);
    // const parsedMinterRoyaltiesMichelsonCode = p.parseMichelineExpression(EditionsMinterRoyaltiesViewCodeType.code)


    // const editions_contract_metadata = {
    //     name: 'A:RT - ',
    //     description: 'Implementation of the edition version of the FA2 standart on Tezos. Big part of the code has been taken on the TQTezos github repo (thanks a lot...). Added some views extension and logic in order to restrict access to a set of addresses (curation) and added a royalties view that can be user on and off-chain.',
    //     interfaces: ['TZIP-012', 'TZIP-016'],
    //     views: [{
    //         name: 'token_metadata',
    //         description: 'Get the metadata for the tokens minted using this contract',
    //         pure: false,
    //         implementations: [
    //             {
    //                 michelsonStorageView:
    //                 {
    //                     parameter: {
    //                         prim: 'nat',
    //                     },
    //                     returnType: {
    //                         prim: "pair",
    //                         args: [
    //                             { prim: "nat", annots: ["%token_id"] },
    //                             { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
    //                         ],
    //                     },
    //                     code: parsedEditionMetadataMichelsonCode,
    //                 },
    //             },
    //         ],
    //     }, {
    //         name: 'minter_royalties',
    //         description: 'Get the address and the percentage to be sent to the minter of the NFTs (royalties) providing the token_id to the view',
    //         pure: false,
    //         implementations: [
    //             {
    //                 michelsonStorageView:
    //                 {
    //                     parameter: {
    //                         prim: 'nat'
    //                     },
    //                     returnType: {
    //                         prim: "pair",
    //                         args: [
    //                             { prim: "address", annots: ["%address"] },
    //                             { prim: "nat", annots: ["%percentage"] }
    //                         ],
    //                     },
    //                     code: parsedMinterRoyaltiesMichelsonCode
    //                 },
    //             },
    //         ],
    //     }],
    // };

    const originateParam = {
        code: code,
        storage: {
            next_edition_id: 0,
            editions_metadata: MichelsonMap.fromLiteral({}),
            max_editions_per_run: 250,
            assets: {
                ledger: MichelsonMap.fromLiteral({}),
                operators: MichelsonMap.fromLiteral({}),
                token_metadata: MichelsonMap.fromLiteral({})
            },
            admin: {
                admin: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
                pause_minting: false,
                pause_nb_edition_minting: false,
                minters: MichelsonMap.fromLiteral({})
            },
            metadata: MichelsonMap.fromLiteral({
                // "": char2Bytes('tezos-storage:content'),
                // "content": editions_meta_encoded
            })
        }
    }

    try {
        const toolkit = await new TezosToolkit('https://ithacanet.ecadinfra.com');

        toolkit.setProvider({ signer: await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) });


        const originationOp = await toolkit.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Fixed price sale (tez) origination error ${jsonError}`));
    }
}

export const deployContracts = async (param: any) => {
    switch (param.title) {
        case "fixed-price":
            await deployFixedPriceContract()
            break;
        case "fa2-editions":        
            await deployEditionContract()
            break;
        default:
            await deployEditionContract()
            await deployFixedPriceContract()
            break;
    }
}

// -- Tests --

async function testFixedPriceContract(): Promise<void> {
    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing admin entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/admin_main.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fixed_price_sale entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/fixed_price_main_sale.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fixed_price_drop entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/fixed_price_main_drop.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing buy_fixed_price entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/fixed_price_main_buy_sale.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing buy_dropped entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/fixed_price_main_buy_drop.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })
}

async function testEditionContract(): Promise<void> {
    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 admin entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/admin.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 operator entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/operator_lib.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 standard entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/standard.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 main (mint and burn) entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/multi_nft_token_editions.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 views entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/views.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })
}

export const testContracts = async (param: any) => {
    switch (param.title) {
        case "fixed-price":
            await testFixedPriceContract()
            break;
        case "fa2-editions":        
            await testEditionContract()
            break;
        default:
            await testEditionContract()
            await testFixedPriceContract()
            break;
    }
}