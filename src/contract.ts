import * as fs from 'fs';
import * as path from 'path';
import * as kleur from 'kleur';
import * as child from 'child_process';

import { loadFile } from './helper';
import { InMemorySigner } from '@taquito/signer';
import { MichelsonMap, TezosToolkit } from '@taquito/taquito';

export async function compileContract(): Promise<void> {

    await new Promise<void>((resolve, reject) =>
        // Compile the contract
        child.exec(
            path.join(__dirname, "../ligo/exec_ligo compile-contract " + path.join(__dirname,  "../ligo/d-art.fixed-price/fixed_price_main.mligo") + " fixed_price_tez_main "),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to compile the contract.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(kleur.green('Contract compiled succesfully at:'))
                    // Write json contract into json file
                    console.log('  ' + path.join(__dirname, '../ligo/d-art.fixed-price/compile/fixed_price_main.tz'))
                    fs.writeFileSync(path.join(__dirname, '../ligo/d-art.fixed-price/compile/fixed_price_main.tz'), stdout)
                    resolve();
                }
            }
        )
    );
}

export async function calculateSize(): Promise<void> {
    await new Promise<void>((resolve, reject) =>
    // Compile the contract
    child.exec(
        path.join(__dirname, "../ligo/exec_ligo measure-contract " + path.join(__dirname,  "../ligo/d-art.fixed-price/fixed_price_main.mligo") + " fixed_price_tez_main "),
        (err, stdout) => {
            if (err) {
                console.log(kleur.red('Failed to calculate the contract size.'));
                console.log(kleur.yellow().dim(err.toString()))
                reject();
            } else {
                console.log(kleur.green(`Contract size: ${stdout}`))
                resolve();
            }
        }
    )
);
}

export async function deployContract(): Promise<void> {
    const code = await loadFile(path.join(__dirname, '../ligo/d-art.fixed-price/compile/fixed_price_main.tz'))

    const originateParam = {
        code: code,
        storage: {
            admin : {
                admin_address : 'tz1cihyVZ8xcFXMEWcdbLdMNABcSfZyNcCbZ', //process.env.ADMIN_ADDRESS,
                pb_key : 'edpkvXH8BHwfDCzEJH98GGhW28aA5bXYY7bLwGVLery5RnKCV1SHAu', //process.env.AUTHORIZATION_PUBLIC_KEY,
                signed_message_used : MichelsonMap.fromLiteral({})
            },
            sales: MichelsonMap.fromLiteral({}),
            for_sale: MichelsonMap.fromLiteral({}),
            authorized_drops_seller: MichelsonMap.fromLiteral({}),
            fa2_dropped: MichelsonMap.fromLiteral({}),
            drops: MichelsonMap.fromLiteral({}),
            fee: {
                fee_percent: 10,
                fee_address: 'tz1cihyVZ8xcFXMEWcdbLdMNABcSfZyNcCbZ', //process.env.ADMIN_ADDRESS
            }
        }
    }

    try {
        const toolkit = new TezosToolkit('http://florence.newby.org:8732');
        console.log(process.env.ADMIN_PRIVATE_KEY)
        toolkit.setProvider({ signer: await InMemorySigner.fromSecretKey('edskS6KddYkywwFvZzDtUD6H3cYFQo3VexRg8L87qrnW2GmwTGGN1CRcaJ4rneSP3fe69u9xhR3prh4ZQFgrfQ5wAF4WAk2o49') });

        const originationOp = await toolkit.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Fixed price sale (tez) origination error ${jsonError}`));
    }
}


