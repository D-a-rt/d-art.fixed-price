"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deployContract = exports.compileContract = void 0;
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const kleur = __importStar(require("kleur"));
const child = __importStar(require("child_process"));
const helper_1 = require("./helper");
const signer_1 = require("@taquito/signer");
const taquito_1 = require("@taquito/taquito");
require('dotenv').config();
function compileContract() {
    return __awaiter(this, void 0, void 0, function* () {
        yield new Promise((resolve, reject) => 
        // Compile the contract
        child.exec(path.join(__dirname, "../ligo/exec_ligo compile-contract " + path.join(__dirname, "../ligo/d-art.fixed-price/fixed_price_main.mligo") + " fixed_price_tez_main "), (err, stdout) => {
            if (err) {
                console.log(kleur.red('Failed to compile the contract.'));
                console.log(kleur.yellow().dim(err.toString()));
                reject();
            }
            else {
                console.log(kleur.green('Contract compiled succesfully at:'));
                // Write json contract into json file
                console.log('  ' + path.join(__dirname, '../ligo/d-art.fixed-price/compile/fixed_price_main.tz'));
                fs.writeFileSync(path.join(__dirname, '../ligo/d-art.fixed-price/compile/fixed_price_main.tz'), stdout);
                resolve();
            }
        }));
    });
}
exports.compileContract = compileContract;
function deployContract() {
    return __awaiter(this, void 0, void 0, function* () {
        const code = yield helper_1.loadFile(path.join(__dirname, '../ligo/d-art.fixed-price/compile/fixed_price_main.tz'));
        const originateParam = {
            code: code,
            storage: {
                admin: {
                    admin_address: process.env.ADMIN_ADDRESS,
                    pb_key: process.env.AUTHORIZATION_PUBLIC_KEY,
                    signed_message_used: taquito_1.MichelsonMap.fromLiteral({})
                },
                sales: taquito_1.MichelsonMap.fromLiteral({}),
                preconfigured_sales: taquito_1.MichelsonMap.fromLiteral({}),
                authorized_drops_seller: taquito_1.MichelsonMap.fromLiteral({}),
                fa2_dropped: taquito_1.MichelsonMap.fromLiteral({}),
                drops: taquito_1.MichelsonMap.fromLiteral({}),
                fee: {
                    fee_percent: 10,
                    fee_address: process.env.ADMIN_ADDRESS
                }
            }
        };
        try {
            const toolkit = new taquito_1.TezosToolkit('https://edonet.smartpy.io');
            toolkit.setProvider({ signer: yield signer_1.InMemorySigner.fromSecretKey(process.env.ADMIN_PRIVATE_KEY) });
            const originationOp = yield toolkit.contract.originate(originateParam);
            yield originationOp.confirmation();
            const { address } = yield originationOp.contract();
            console.log('Contract deployed at: ', address);
        }
        catch (error) {
            const jsonError = JSON.stringify(error);
            console.log(kleur.red(`Fixed price sale (tez) origination error ${jsonError}`));
        }
    });
}
exports.deployContract = deployContract;
//# sourceMappingURL=contract.js.map