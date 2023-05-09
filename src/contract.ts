require('dotenv').config()
import * as fs from 'fs';
import * as path from 'path';
import * as kleur from 'kleur';
import * as child from 'child_process';

import { loadFile } from './helper';
import { NFTStorage } from 'nft.storage';
import { char2Bytes } from '@taquito/tzip16';
import { Parser } from '@taquito/michel-codec';
import { InMemorySigner } from '@taquito/signer';
import { MichelsonMap, TezosToolkit } from '@taquito/taquito';

// -- View import

// Fa2 space originated
import {
    TokenMetadataViewSpace,
    RoyaltyDistributionViewSpace,
    SplitsViewSpace,
    RoyaltySplitsViewSpace,
    RoyaltyViewSpace,
    MinterViewSpace,
    IsTokenMinterViewSpace,
    CommissionSplitsViewSpace
} from './views/fa2_editions_space.tz';

// FA2 Legacy
import {
    TokenMetadataViewLegacy,
    RoyaltyDistributionViewLegacy,
    SplitsViewLegacy,
    RoyaltySplitsViewLegacy,
    RoyaltyViewLegacy,
    MinterViewLegacy,
    IsTokenMinterViewLegacy
} from './views/fa2_editions_legacy.tz';

// FA2 Serie
import {
    TokenMetadataViewSerie,
    RoyaltyDistributionViewSerie,
    SplitsViewRoyalty,
    RoyaltySplitsViewSerie,
    RoyaltyViewSerie,
    MinterViewSerie,
    IsTokenMinterViewSerie
} from './views/fa2_editions_serie.tz';
import { sendJSONToIPFS } from './ipfs';
import { LedgerSigner } from '@taquito/ledger-signer';
import TransportNodeHid from '@ledgerhq/hw-transport-node-hid';


const client = new NFTStorage({
    token: process.env.NFT_STORAGE_KEY!,
})

export enum ContractAction {
    COMPILE = "compile contract",
    SIZE = "info measure-contract"
}

async function contractAction(contractName: string, action: ContractAction, pathString: string, mainFunction: string, compilePath?: string): Promise<void> {
    await new Promise<void>((resolve, reject) =>
        child.exec(
            path.join(`./ligo/exec_ligo ${action} ` + path.join(`./ligo/${pathString}`) + ` -e ${mainFunction}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to compile the contract.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    // Write json contract into json file
                    if (action === ContractAction.COMPILE) {
                        console.log(kleur.green(`Compiled ${contractName} contract succesfully at: `))
                        console.log('  ' + `./ligo/${compilePath}`)
                        fs.writeFileSync(`./ligo/${compilePath}`, stdout)
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

export async function contracts(param: any, type: ContractAction): Promise<void> {
    switch (param.title) {
        case "fixed-price":
            contractAction("Fixed-price", type, "there.fixed-price/fixed_price_main.mligo", "fixed_price_main", "there.fixed-price/compile/fixed_price_main.tz")
            break;
        case "fa2-editions":
            contractAction("Fa2 editions", type, "there.fa2-editions/compile_fa2_editions.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition'", "there.fa2-editions/compile/multi_nft_token_editions.tz")
            break;
        case "fa2-editions-serie":
            contractAction("Fa2 editions serie", type, "there.fa2-editions/compile_fa2_editions_serie.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition'", "there.art-factories/compile/serie.tz")
            break;
        case "fa2-editions-space":
            contractAction("Fa2 editions space", type, "there.fa2-editions/compile_fa2_editions_space.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition, commission_splits'", "there.art-factories/compile/space.tz")
            break;
        case "serie-factory":
            contractAction("Serie factory", type, "there.art-factories/serie_factory.mligo", "serie_factory_main", "there.art-factories/compile/serie_factory.tz")
            break;
        case "space-factory":
            contractAction("Space factory", type, "there.art-factories/space_factory.mligo", "space_factory_main", "there.art-factories/compile/space_factory.tz")
            break;
        case "permission-manager":
            contractAction("Permission manager", type, "there.permission-manager/permission_manager.mligo", "permission_manager_main", "there.permission-manager/compile/permission_manager.tz")
            break;
        default:
            contractAction("Fixed-price", type, "there.fixed-price/fixed_price_main.mligo", "fixed_price_main", "there.fixed-price/compile/fixed_price_main.tz")
            contractAction("Fa2 editions", type, "there.fa2-editions/compile_fa2_editions.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition'", "there.fa2-editions/compile/multi_nft_token_editions.tz")
            contractAction("Fa2 editions factory", type, "there.fa2-editions/compile_fa2_editions_serie.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition'", "there.art-factories/compile/serie.tz")
            contractAction("Fa2 editions space", type, "there.fa2-editions/compile_fa2_editions_space.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition, commission_splits'", "there.art-factories/compile/space.tz")
            contractAction("Serie factory", type, "there.art-factories/serie_factory.mligo", "serie_factory_main", "there.art-factories/compile/serie_factory.tz")
            contractAction("Space factory", type, "there.art-factories/space_factory.mligo", "space_factory_main", "there.art-factories/compile/space_factory.tz")
            contractAction("Permission manager", type, "there.permission-manager/views.mligo", "permission_manager_main --views 'is_minter, is_space_manager, is_auction_house_manager, is_admin'", "there.permission-manager/compile/permission_manager.tz")
            break;
    }
}

// -- Deploy contracts --

export async function deployFixedPriceContract(permissionManager: string): Promise<void> {
    const code = await loadFile('./ligo/there.fixed-price/compile/fixed_price_main.tz')

    const fixed_price_contract_metadata = {
        name: 'there. - Marketplace (fixed price)',
        description: 'Marketplace contract focus on fixed price sales and schedule sales.',
        authors: 'tz1PpLjzEpGgozBVrjMVG6iEfsM3nKyrqbN2',
        homepage: 'https://there.art',
        license: "MIT",
        interfaces: ['TZIP-016'],
        imageUri: "ipfs://QmawwNzA6twuCcWFfaS1TNm5rAntYHpsfjXNFg7w4TjYmT"
    }

    const contractMetaHash = await sendJSONToIPFS(fixed_price_contract_metadata, "there_fixed_price_contract_v1_metadata")

    if (!contractMetaHash) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    const originateParam = {
        code: code,
        storage: {
            admin: {
                permission_manager: permissionManager,
                contract_will_update: false
            },
            for_sale: MichelsonMap.fromLiteral({}),
            drops: MichelsonMap.fromLiteral({}),
            fa2_sold: MichelsonMap.fromLiteral({}),
            fa2_dropped: MichelsonMap.fromLiteral({}),
            offers: MichelsonMap.fromLiteral({}),
            fee_primary: {
                address: process.env.ENV === 'PROD' ? process.env.TREASURY_PROD_PUBLIC_KEY_HASH : process.env.TREASURY_PUBLIC_KEY_HASH,
                percent: 100,
            },
            fee_secondary: {
                address: process.env.ENV === 'PROD' ? process.env.TREASURY_PROD_PUBLIC_KEY_HASH : process.env.TREASURY_PUBLIC_KEY_HASH,
                percent: 25,
            },
            stable_coin: MichelsonMap.fromLiteral({}),
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetaHash}`),
            })
        }
    }

    try {
        if (!process.env.RPC_URL) return console.log(kleur.red(`Please set the RPC_URL in the .env file.`));
        if (!process.env.ORIGINATOR_PRIVATE_KEY && process.env.RPC_URL === '') return console.log(kleur.red(`Please set the ORIGINATOR_PRIVATE_KEY in the .env file.`));

        const Tezos = await new TezosToolkit(process.env.RPC_URL);

        const transport = await TransportNodeHid.create();
        const ledgerSigner = new LedgerSigner(transport);

        Tezos.setProvider({ signer: process.env.ENV === 'DEV' ? await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) : ledgerSigner });

        //Get the public key and the public key hash from the Ledger
        const publicKey = await Tezos.signer.publicKey();
        const publicKeyHash = await Tezos.signer.publicKeyHash();

        console.log('Public key: ', publicKey)
        console.log('Public key hash: ', publicKeyHash)

        const originationOp = await Tezos.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Fixed price contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Fixed price sale (tez) origination error ${jsonError}`));
    }
}

export async function deployLegacyContract(permisionManagerAdd: string): Promise<void> {
    const code = await loadFile('./ligo/there.fa2-editions/compile/multi_nft_token_editions.tz')

    const p = new Parser();

    const parsedSplitsMichelsonCode = p.parseMichelineExpression(SplitsViewLegacy.code);
    const parsedMinterMichelsonCode = p.parseMichelineExpression(MinterViewLegacy.code);
    const parsedRoyaltyMichelsonCode = p.parseMichelineExpression(RoyaltyViewLegacy.code);
    const parsedIsTokenMinterMichelsonCode = p.parseMichelineExpression(IsTokenMinterViewLegacy.code);
    const parsedRoyaltySplitsMichelsonCode = p.parseMichelineExpression(RoyaltySplitsViewLegacy.code);
    const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(TokenMetadataViewLegacy.code);
    const parsedRoyaltyDistributionMichelsonCode = p.parseMichelineExpression(RoyaltyDistributionViewLegacy.code);

    const editions_contract_metadata = {
        name: 'Legacy',
        description: "The Legacy Series stands as a tribute to the spirit of our platform. A one-of-a-kind serie that belongs to us all, each accepted creator is invited to mint a single, unique edition to make their mark in the annals of our community. Come and see the history we're making together.",
        authors: 'tz1PpLjzEpGgozBVrjMVG6iEfsM3nKyrqbN2',
        homepage: 'https://there.art',
        license: "MIT",
        interfaces: ['TZIP-012', 'TZIP-016'],
        imageUri: "ipfs://QmRUTXrfMxytNNh9WtZDeqp3TihSn29BgktWEssrf2cVvJ",
        views: [{
            name: 'token_metadata',
            description: 'Get the metadata for the tokens minted using this contract',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %token_id) (map %token_info string bytes))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%token_id"] },
                                { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
                            ],
                        },
                        code: parsedEditionMetadataMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_distribution',
            description: 'Get the minter of a specify token as well as the amount of royalty and the splits corresponding to it.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair address (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct)))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "address" },
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "nat", annots: ["%royalty"] },
                                        {
                                            prim: "list",
                                            args: [
                                                {
                                                    prim: "pair",
                                                    args: [
                                                        { prim: "address", annots: ["%address"] },
                                                        { prim: "nat", annots: ["%pct"] },
                                                    ]
                                                }
                                            ],
                                            annots: ["%splits"]
                                        },
                                    ]
                                },
                            ],
                        },
                        code: parsedRoyaltyDistributionMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'splits',
            description: 'Get the splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (list (pair (address %address) (nat %pct)))
                        returnType: {
                            prim: "list",
                            args: [
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "address", annots: ["%address"] },
                                        { prim: "nat", annots: ["%pct"] },
                                    ]
                                }
                            ],
                            annots: ["%splits"]
                        },
                        code: parsedSplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_splits',
            description: 'Get the royalty and splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%royalty"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                },
                            ]
                        },
                        code: parsedRoyaltySplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty',
            description: 'Get the royalty for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'nat',
                        },
                        code: parsedRoyaltyMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'minter',
            description: 'Get the minter for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'address',
                        },
                        code: parsedMinterMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'is_token_minter',
            description: 'Verify if address is minter on the contract.',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'pair',
                            args: [
                                { prim: "address" },
                                { prim: "nat" }
                            ]
                        },
                        // nat
                        returnType: {
                            prim: 'bool',
                        },
                        code: parsedIsTokenMinterMichelsonCode,
                    },
                },
            ],
        }],
    };

    const contractMetaHash = await sendJSONToIPFS(editions_contract_metadata, "there_legacy_metadata")

    if (!contractMetaHash) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    const originateParam = {
        code: code,
        storage: {
            next_token_id: 0,
            max_editions_per_run: 1,
            as_minted: MichelsonMap.fromLiteral({}),
            proposals: MichelsonMap.fromLiteral({}),
            editions_metadata: MichelsonMap.fromLiteral({}),
            assets: {
                ledger: MichelsonMap.fromLiteral({}),
                operators: MichelsonMap.fromLiteral({}),
                token_metadata: MichelsonMap.fromLiteral({})
            },
            admin: {
                pause_minting: false,
                permission_manager: permisionManagerAdd,
            },
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetaHash}`),
                "symbol": char2Bytes("th:r")
            })
        }
    }

    try {
        if (!process.env.RPC_URL) return console.log(kleur.red(`Please set the RPC_URL in the .env file.`));
        if (!process.env.ORIGINATOR_PRIVATE_KEY && process.env.RPC_URL === '') return console.log(kleur.red(`Please set the ORIGINATOR_PRIVATE_KEY in the .env file.`));

        const Tezos = await new TezosToolkit(process.env.RPC_URL);

        const transport = await TransportNodeHid.create();
        const ledgerSigner = new LedgerSigner(transport);

        Tezos.setProvider({ signer: process.env.ENV === 'DEV' ? await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) : ledgerSigner });

        const originationOp = await Tezos.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Edition FA2 contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Edition FA2 origination error ${jsonError}`));
    }
}

export async function deploySerieFactory(permisionManagerAdd: string): Promise<void> {
    const code = await loadFile('./ligo/there.art-factories/compile/serie_factory.tz')

    const serieFactoryMetadata = {
        name: 'there. - Serie factory',
        description: 'The Serie Factory contract is the backbone of our platform, allowing creators to launch their own smart contracts and mint unique digital artworks. With this powerful tool, our creators can unleash their boundless imagination and bring their artistic vision to life.',
        authors: 'tz1PpLjzEpGgozBVrjMVG6iEfsM3nKyrqbN2',
        homepage: 'https://there.art',
        license: "MIT",
        interfaces: ['TZIP-016']
    }

    const contractMetaHash = await sendJSONToIPFS(serieFactoryMetadata, "there_serie_factory_metadata")

    if (!contractMetaHash) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    const originateParam = {
        code: code,
        storage: {
            permission_manager: permisionManagerAdd,
            series: MichelsonMap.fromLiteral({}),
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetaHash}`),
            }),
            next_serie_id: 0
        }
    }

    try {
        if (!process.env.RPC_URL) return console.log(kleur.red(`Please set the RPC_URL in the .env file.`));
        if (!process.env.ORIGINATOR_PRIVATE_KEY && process.env.RPC_URL === '') return console.log(kleur.red(`Please set the ORIGINATOR_PRIVATE_KEY in the .env file.`));

        const Tezos = await new TezosToolkit(process.env.RPC_URL);

        const transport = await TransportNodeHid.create();
        const ledgerSigner = new LedgerSigner(transport);

        Tezos.setProvider({ signer: process.env.ENV === 'DEV' ? await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) : ledgerSigner });

        const originationOp = await Tezos.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Serie Factory contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Serie Factory origination error ${jsonError}`));
    }
}

export async function deploySpaceFactory(permisionManagerAdd: string): Promise<void> {
    const code = await loadFile('./ligo/there.art-factories/compile/space_factory.tz')

    const spaceFactoryMetadata = {
        name: 'there. - Space factory',
        description: 'Introducing the Space Factory - the innovative smart contract that empowers curators to create their own curated spaces on our platform. With the Space Factory, curators can customize their spaces, manage their creators, and showcase their unique curation to the world. Join us today and discover the endless possibilities of digital curation!',
        authors: 'tz1PpLjzEpGgozBVrjMVG6iEfsM3nKyrqbN2',
        homepage: 'https://there.art',
        license: "MIT",
        interfaces: ['TZIP-016']
    }

    const contractMetaHash = await sendJSONToIPFS(spaceFactoryMetadata, "there_space_factory_metadata")

    if (!contractMetaHash) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    const originateParam = {
        code: code,
        storage: {
            permission_manager: permisionManagerAdd,
            spaces: MichelsonMap.fromLiteral({}),
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetaHash}`),
            })
        }
    }

    try {
        if (!process.env.RPC_URL) return console.log(kleur.red(`Please set the RPC_URL in the .env file.`));
        if (!process.env.ORIGINATOR_PRIVATE_KEY && process.env.RPC_URL === '') return console.log(kleur.red(`Please set the ORIGINATOR_PRIVATE_KEY in the .env file.`));

        const Tezos = await new TezosToolkit(process.env.RPC_URL);

        const transport = await TransportNodeHid.create();
        const ledgerSigner = new LedgerSigner(transport);

        Tezos.setProvider({ signer: process.env.ENV === 'DEV' ? await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) : ledgerSigner });

        const originationOp = await Tezos.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Space Factory contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Space Factory origination error ${jsonError}`));
    }
}

export async function deployPermissionManager(): Promise<string | undefined> {
    const code = await loadFile('./ligo/there.permission-manager/compile/permission_manager.tz')

    const permissionManagerMetadata = {
        name: 'there. - Permission manager',
        description: 'This contract is responsible to manage access on there.',
        authors: 'tz1PpLjzEpGgozBVrjMVG6iEfsM3nKyrqbN2',
        homepage: 'https://there.art',
        license: "MIT",
        interfaces: ['TZIP-016']
    }

    const contractMetaHash = await sendJSONToIPFS(permissionManagerMetadata, "there_permission_manager_metadata")

    if (!contractMetaHash) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        throw Error('Unable to upload data to ipfs')
    }

    const originateParam = {
        code: code,
        storage: {
            admin_str: {
                admin: process.env.ENV === 'PROD' ? process.env.ADMIN_PROD_PUBLIC_KEY_HASH : process.env.ADMIN_PUBLIC_KEY_HASH,
                pending_admin: null,
            },
            minters: MichelsonMap.fromLiteral({}),
            space_managers: MichelsonMap.fromLiteral({}),
            auction_house_managers: MichelsonMap.fromLiteral({}),
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetaHash}`),
            })
        }
    }

    try {
        if (!process.env.RPC_URL) throw console.log(kleur.red(`Please set the RPC_URL in the .env file.`));
        if (!process.env.ORIGINATOR_PRIVATE_KEY && process.env.ENV === 'DEV') throw console.log(kleur.red(`Please set the ORIGINATOR_PRIVATE_KEY in the .env file.`));

        const Tezos = await new TezosToolkit(process.env.RPC_URL);

        const transport = await TransportNodeHid.create();
        const ledgerSigner = new LedgerSigner(transport);

        Tezos.setProvider({ signer: process.env.ENV === 'DEV' ? await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) : ledgerSigner });

        const originationOp = await Tezos.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Permission manager contract deployed at: ', address)
        return address
    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Permission manager origination error ${jsonError}`));
    }
}

export const deployContracts = async (param: any) => {
    switch (param.title) {
        case "fixed-price":
            if (param.permissionManager) await deployFixedPriceContract(param.permissionManager)
            break;
        case "fa2-editions":
            if (param.permissionManager) await deployLegacyContract(param.permissionManager)
            break;
        case "serie-factory":
            if (param.permissionManager) await deploySerieFactory(param.permissionManager)
            break;
        case "space-factory":
            console.log(param.permissionManager)
            if (param.permissionManager) await deploySpaceFactory(param.permissionManager)
            break;
        case "permission-manager":
            await deployPermissionManager()
            break;
        default:
            const permissionManagerAdd = await deployPermissionManager()
            if (permissionManagerAdd) await deployLegacyContract(permissionManagerAdd)
            if (permissionManagerAdd) await deployFixedPriceContract(permissionManagerAdd)
            if (permissionManagerAdd) await deploySerieFactory(permissionManagerAdd)
            if (permissionManagerAdd) await deploySpaceFactory(permissionManagerAdd)
            break;
    }
}

// -- Tests --

async function testFixedPriceContract(): Promise<void> {
    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing admin entrypoints...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fixed-price/admin_main.test.mligo`,
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

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fixed-price/fixed_price_main_sale.test.mligo`,
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

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fixed-price/fixed_price_main_drop.test.mligo`,
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

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fixed-price/fixed_price_main_buy_sale.test.mligo`,
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

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fixed-price/fixed_price_main_buy_drop.test.mligo`,
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

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fa2-editions/admin.test.mligo`,
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))

                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 operator entrypoints...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fa2-editions/operator_lib.test.mligo`,
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

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fa2-editions/standard.test.mligo`,
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
        console.log(kleur.green(`Testing fa2 main (mint and burn) entrypoints for fa2_editions...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fa2-editions/fa2_editions.test.mligo`,
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
        console.log(kleur.green(`Testing fa2 main (mint and burn) entrypoints for fa2_editions_serie...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.fa2-editions/fa2_editions_serie.test.mligo`,
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
        console.log(kleur.green(`Testing fa2 main (mint and burn) entrypoints for fa2_editions_space...`))

        child.exec(
            `./ligo/exec_ligo run test ./ligo/test/there.fa2-editions/fa2_editions_space.test.mligo`,
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
            `./ligo/exec_ligo run test ./ligo/test/there.fa2-editions/views.test.mligo`,
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

async function testSerieFactoryContract(): Promise<void> {

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing serie factory main entrypoints...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.art-factories/serie_factory_main.test.mligo`,
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

async function testSpaceFactoryContract(): Promise<void> {
    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing space factory main entrypoints...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.art-factories/space_factory_main.test.mligo`,
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

async function testPermissionManagerContract(): Promise<void> {

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing permission manager main entrypoints...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.permission-manager/permission_manager.test.mligo`,
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
        console.log(kleur.green(`Testing permission manager views entrypoints...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.permission-manager/views.test.mligo`,
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
        console.log(kleur.green(`Testing permission manager admin entrypoints...`))

        child.exec(`./ligo/exec_ligo run test ./ligo/test/there.permission-manager/admin.test.mligo`,
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
        case "serie-factory":
            await testSerieFactoryContract()
            break;
        case "space-factory":
            await testSpaceFactoryContract()
            break;
        case "permission-manager":
            await testPermissionManagerContract()
            break;
        default:
            console.log(kleur.magenta(`Testing editions contracts:`))
            console.log(kleur.magenta(` `))
            await testEditionContract()
            console.log(kleur.magenta(`Testing fixed price contracts:`))
            console.log(kleur.magenta(` `))
            await testFixedPriceContract()
            console.log(kleur.magenta(`Testing serie factory contracts:`))
            console.log(kleur.magenta(` `))
            await testSerieFactoryContract()
            console.log(kleur.magenta(`Testing space factory contracts:`))
            console.log(kleur.magenta(` `))
            await testSpaceFactoryContract()
            console.log(kleur.magenta(`Testing permission manager contracts:`))
            console.log(kleur.magenta(` `))
            await testPermissionManagerContract()
            break;
    }
}

// Example metadata upload for Legacy contracts
export const uploadContractMetadataLegacy = async () => {

    const p = new Parser();

    const parsedSplitsMichelsonCode = p.parseMichelineExpression(SplitsViewLegacy.code);
    const parsedMinterMichelsonCode = p.parseMichelineExpression(MinterViewLegacy.code);
    const parsedRoyaltyMichelsonCode = p.parseMichelineExpression(RoyaltyViewLegacy.code);
    const parsedIsTokenMinterMichelsonCode = p.parseMichelineExpression(IsTokenMinterViewLegacy.code);
    const parsedRoyaltySplitsMichelsonCode = p.parseMichelineExpression(RoyaltySplitsViewLegacy.code);
    const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(TokenMetadataViewLegacy.code);
    const parsedRoyaltyDistributionMichelsonCode = p.parseMichelineExpression(RoyaltyDistributionViewLegacy.code);

    const editions_contract_metadata = {
        name: 'THR - Legacy',
        description: 'The lecgacy contract for THERE NFTs, is the genesis of THR tokens. Where all curated artist can create only one unique piece.',
        authors: 'tz1PpLjzEpGgozBVrjMVG6iEfsM3nKyrqbN2',
        interfaces: ['TZIP-012', 'TZIP-016'],
        imageUri: "ipfs://QmUxNNqSrsDK5JLk42u2iwwFkP8osFM2pcfYRuEZKsmwrL",
        imageUriSvg: true, // Or false if not
        headerLogo: "ipfs://Qmf4LS9HgwYSWVq73AL1HVaaeW1s44qJvZuUDJkVyTEKze",
        headerLogoSvg: true, // Or false if not
        views: [{
            name: 'token_metadata',
            description: 'Get the metadata for the tokens minted using this contract',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %token_id) (map %token_info string bytes))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%token_id"] },
                                { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
                            ],
                        },
                        code: parsedEditionMetadataMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_distribution',
            description: 'Get the minter of a specify token as well as the amount of royalty and the splits corresponding to it.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair address (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct)))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "address" },
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "nat", annots: ["%royalty"] },
                                        {
                                            prim: "list",
                                            args: [
                                                {
                                                    prim: "pair",
                                                    args: [
                                                        { prim: "address", annots: ["%address"] },
                                                        { prim: "nat", annots: ["%pct"] },
                                                    ]
                                                }
                                            ],
                                            annots: ["%splits"]
                                        },
                                    ]
                                },
                            ],
                        },
                        code: parsedRoyaltyDistributionMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'splits',
            description: 'Get the splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (list (pair (address %address) (nat %pct)))
                        returnType: {
                            prim: "list",
                            args: [
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "address", annots: ["%address"] },
                                        { prim: "nat", annots: ["%pct"] },
                                    ]
                                }
                            ],
                            annots: ["%splits"]
                        },
                        code: parsedSplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_splits',
            description: 'Get the royalty and splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%royalty"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                },
                            ]
                        },
                        code: parsedRoyaltySplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty',
            description: 'Get the royalty for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'nat',
                        },
                        code: parsedRoyaltyMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'minter',
            description: 'Get the minter for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'address',
                        },
                        code: parsedMinterMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'is_token_minter',
            description: 'Verify if address is minter on the contract.',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'pair',
                            args: [
                                { prim: "address" },
                                { prim: "nat" }
                            ]
                        },
                        // nat
                        returnType: {
                            prim: 'bool',
                        },
                        code: parsedIsTokenMinterMichelsonCode,
                    },
                },
            ],
        }],
    };

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(editions_contract_metadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    console.log(contractMetadata)
}

// Example metadata upload for serie factory generated contracts
export const uploadContractMetadataSerie = async () => {

    const p = new Parser();

    const parsedSplitsMichelsonCode = p.parseMichelineExpression(SplitsViewRoyalty.code);
    const parsedMinterMichelsonCode = p.parseMichelineExpression(MinterViewSerie.code);
    const parsedRoyaltyMichelsonCode = p.parseMichelineExpression(RoyaltyViewSerie.code);
    const parsedIsTokenMinterMichelsonCode = p.parseMichelineExpression(IsTokenMinterViewSerie.code);
    const parsedRoyaltySplitsMichelsonCode = p.parseMichelineExpression(RoyaltySplitsViewSerie.code);
    const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(TokenMetadataViewSerie.code);
    const parsedRoyaltyDistributionMichelsonCode = p.parseMichelineExpression(RoyaltyDistributionViewSerie.code);

    const editions_contract_metadata = {
        name: 'THR Space',
        description: 'We present work across all media including painting, drawing, sculpture, installation, photography and video and we seek to cultivate the lineages that run between emerging and established artists.',
        authors: 'tz1PpLjzEpGgozBVrjMVG6iEfsM3nKyrqbN2',
        interfaces: ['TZIP-012', 'TZIP-016'],
        imageUri: "ipfs://QmUxNNqSrsDK5JLk42u2iwwFkP8osFM2pcfYRuEZKsmwrL",
        views: [{
            name: 'token_metadata',
            description: 'Get the metadata for the tokens minted using this contract',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %token_id) (map %token_info string bytes))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%token_id"] },
                                { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
                            ],
                        },
                        code: parsedEditionMetadataMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_distribution',
            description: 'Get the minter of a specify token as well as the amount of royalty and the splits corresponding to it.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair address (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct)))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "address" },
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "nat", annots: ["%royalty"] },
                                        {
                                            prim: "list",
                                            args: [
                                                {
                                                    prim: "pair",
                                                    args: [
                                                        { prim: "address", annots: ["%address"] },
                                                        { prim: "nat", annots: ["%pct"] },
                                                    ]
                                                }
                                            ],
                                            annots: ["%splits"]
                                        },
                                    ]
                                },
                            ],
                        },
                        code: parsedRoyaltyDistributionMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'splits',
            description: 'Get the splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (list (pair (address %address) (nat %pct)))
                        returnType: {
                            prim: "list",
                            args: [
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "address", annots: ["%address"] },
                                        { prim: "nat", annots: ["%pct"] },
                                    ]
                                }
                            ],
                            annots: ["%splits"]
                        },
                        code: parsedSplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_splits',
            description: 'Get the royalty and splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%royalty"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                },
                            ]
                        },
                        code: parsedRoyaltySplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty',
            description: 'Get the royalty for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'nat',
                        },
                        code: parsedRoyaltyMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'minter',
            description: 'Get the minter for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'address',
                        },
                        code: parsedMinterMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'is_token_minter',
            description: 'Verify if address is minter on the contract.',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'pair',
                            args: [
                                { prim: "address" },
                                { prim: "nat" }
                            ]
                        },
                        // nat
                        returnType: {
                            prim: 'bool',
                        },
                        code: parsedIsTokenMinterMichelsonCode,
                    },
                },
            ],
        }],
    };

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(editions_contract_metadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    console.log(contractMetadata)
}

// Example metadata upload for space factory generated contracts
export const uploadContractMetadataSpace = async () => {

    const p = new Parser();

    const parsedSplitsMichelsonCode = p.parseMichelineExpression(SplitsViewSpace.code);
    const parsedMinterMichelsonCode = p.parseMichelineExpression(MinterViewSpace.code);
    const parsedRoyaltyMichelsonCode = p.parseMichelineExpression(RoyaltyViewSpace.code);
    const parsedIsTokenMinterMichelsonCode = p.parseMichelineExpression(IsTokenMinterViewSpace.code);
    const parsedRoyaltySplitsMichelsonCode = p.parseMichelineExpression(RoyaltySplitsViewSpace.code);
    const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(TokenMetadataViewSpace.code);
    const parsedRoyaltyDistributionMichelsonCode = p.parseMichelineExpression(RoyaltyDistributionViewSpace.code);
    const parsedCommissionSplitsSpaceMichelsonCode = p.parseMichelineExpression(CommissionSplitsViewSpace.code);

    const editions_contract_metadata = {
        name: 'THR Space',
        description: 'We present work across all media including painting, drawing, sculpture, installation, photography and video and we seek to cultivate the lineages that run between emerging and established artists.',
        authors: 'tz1PpLjzEpGgozBVrjMVG6iEfsM3nKyrqbN2',
        interfaces: ['TZIP-012', 'TZIP-016'],
        imageUri: "ipfs://QmUxNNqSrsDK5JLk42u2iwwFkP8osFM2pcfYRuEZKsmwrL",
        imageUriSvg: true,
        headerLogo: "ipfs://Qmf4LS9HgwYSWVq73AL1HVaaeW1s44qJvZuUDJkVyTEKze",
        headerLogoSvg: true,
        views: [{
            name: 'token_metadata',
            description: 'Get the metadata for the tokens minted using this contract',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %token_id) (map %token_info string bytes))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%token_id"] },
                                { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
                            ],
                        },
                        code: parsedEditionMetadataMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_distribution',
            description: 'Get the minter of a specify token as well as the amount of royalty and the splits corresponding to it.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair address (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct)))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "address" },
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "nat", annots: ["%royalty"] },
                                        {
                                            prim: "list",
                                            args: [
                                                {
                                                    prim: "pair",
                                                    args: [
                                                        { prim: "address", annots: ["%address"] },
                                                        { prim: "nat", annots: ["%pct"] },
                                                    ]
                                                }
                                            ],
                                            annots: ["%splits"]
                                        },
                                    ]
                                },
                            ],
                        },
                        code: parsedRoyaltyDistributionMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'splits',
            description: 'Get the splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (list (pair (address %address) (nat %pct)))
                        returnType: {
                            prim: "list",
                            args: [
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "address", annots: ["%address"] },
                                        { prim: "nat", annots: ["%pct"] },
                                    ]
                                }
                            ],
                            annots: ["%splits"]
                        },
                        code: parsedSplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_splits',
            description: 'Get the royalty and splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%royalty"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                },
                            ]
                        },
                        code: parsedRoyaltySplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'commission_splits',
            description: 'Get the commission and splits from the space for a token id',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%commission_pct"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                }
                            ]
                        },
                        code: parsedCommissionSplitsSpaceMichelsonCode,
                    }
                }
            ]
        }, {
            name: 'royalty',
            description: 'Get the royalty for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'nat',
                        },
                        code: parsedRoyaltyMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'minter',
            description: 'Get the minter for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'address',
                        },
                        code: parsedMinterMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'is_token_minter',
            description: 'Verify if address is minter on the contract.',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'pair',
                            args: [
                                { prim: "address" },
                                { prim: "nat" }
                            ]
                        },
                        // nat
                        returnType: {
                            prim: 'bool',
                        },
                        code: parsedIsTokenMinterMichelsonCode,
                    },
                },
            ],
        }],
    };

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(editions_contract_metadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    console.log(contractMetadata)
}