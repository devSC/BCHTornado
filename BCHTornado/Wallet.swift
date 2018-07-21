//
//  Wallet.swift
//  BCHTornado
//
//  Created by Song Xiaofeng on 21/07/2018.
//  Copyright © 2018 hufubit. All rights reserved.
//

import Foundation

import Result
import KeychainSwift
import BigInt

class Wallet {
    let keychain: BTCKeychain
    
    
    var mainAddress: String {
        return keychain.key.compressedPublicKeyAddress.string
    }
    
    var unit: String {
        return "BCH"
    }
    
    var gasUnit: String {
        return "BCH"
    }
    
    var gasLimit: String? {
        return "1000"
    }
    
    
    private let estimateTransactionSize = BigUInt(1_000)
    
    required init(mnemonic: String) {
        let words = mnemonic.components(separatedBy: " ")
        let mnemonic = Mnemonic(words: words)
        guard let seed = mnemonic?.seed else {
            fatalError("seeds can't be nil")
        }
        let rootKeychain = BTCKeychain(seed: seed)
        //to changed
        guard let derivedKeychain = rootKeychain?.derivedKeychain(withPath: "m/44'/145'/0'/0/0") else {
            fatalError("keychain can't be nil")
        }
        
        //xpubKeychain
        keychain = derivedKeychain
        
    }
    
    func getPrivateKey() -> Data? {

        let privateKey: Data = keychain.key.privateKey as Data
        guard let key = BTCKey(privateKey: privateKey),
            key.compressedPublicKeyAddress.string == mainAddress else {
                return nil
        }
        return privateKey
    }
    
//    func transformReceiverAndAmount(toValues: Array<[String: BigInt]>) -> Array<[BTCAddress: BigInt]> {
//        toValues.forEach { (receiveInfo) in
//            receiveInfo.
//        }
//    }
    
    func sign(toValues: Array<ReceiveInfo>) throws -> BTCTransaction {
        let privateKey = getPrivateKey()!
        let key = BTCKey(privateKey: privateKey)
        let fee: BTCAmount = 1000
        let (nilableTransaction, error) = transactionSpendingFrom(privateKey: privateKey,
                                                                  destinationAddressAmounts: toValues,
                                                                  changeAddress: key!.compressedPublicKeyAddress,
                                                                  fee: fee)
        guard let bchTransaction = nilableTransaction else {
            print("error: \(String(describing: error))")
            fatalError("sign errore")
        }

        return bchTransaction
//        return Transaction(payment: payment, hash: btcTransaction.data, hashString: btcTransaction.data.toHexString(), txhash: btcTransaction.transactionID)
    }
    
    func checkIsValid(address: String?) -> Bool {
        guard let address = address, BTCAddress(string: address) != nil else { return false }
        return true
    }
    
    func estimateAmountGas(with gasPrice: Float, gasLimit: UInt? = nil) -> BigUInt {
        //to btc units
        let bigintValue = BigUInt(gasPrice.int)
        let estimateSize = BigUInt(gasLimit ?? UInt(self.gasLimit!)!)
        return estimateSize.multiplied(by: bigintValue)
    }
    
}

extension Wallet {
    func transactionSpendingFrom(privateKey: Data,
                                 destinationAddressAmounts: Array<ReceiveInfo>,
                                 changeAddress: BTCPublicKeyAddress,
                                 fee: BTCAmount) -> (BTCTransaction?, Error?) {
        // 1. Get a private key, destination address, change address and amount
        // 2. Get unspent outputs for that key (using both compressed and non-compressed pubkey)
        // 3. Take the smallest available outputs to combine into the inputs of new transaction
        // 4. Prepare the scripts with proper signatures for the inputs
        // 5. Broadcast the transaction
        
        let key = BTCKey(privateKey: privateKey)!
        var errorOut: Error?
        var unwrappedUtxos: [BTCTransactionOutput]?
        do {
            unwrappedUtxos = try BitboxApi().unspentOutputs(withAddress: key.compressedPublicKeyAddress.string) as? [BTCTransactionOutput]
        } catch {
            errorOut = error
        }
        print("UTXOs for \(key.compressedPublicKeyAddress): \(String(describing: unwrappedUtxos)) \(String(describing: errorOut))")
        
        //sort
        unwrappedUtxos?.sort(by: { $0.value < $1.value })
        guard let utxos = unwrappedUtxos else {
            return (nil, errorOut)
        }
        
        var receiveAmount: BigInt = BigInt()
        destinationAddressAmounts.forEach { receiveInfo in
            receiveAmount = receiveAmount + receiveInfo.amount
        }
        // Find enough outputs to spend the total amount.
        let totalAmount = Int64(receiveAmount) + fee
        
        // We need to avoid situation when change is very small. In such case we should leave smallest coin alone and add some bigger one.
        // Ideally, we need to maintain more-or-less binary distribution of coins: having 0.001, 0.002, 0.004, 0.008, 0.016, 0.032, 0.064, 0.128, 0.256, 0.512, 1.024 etc.
        // Another option is to spend a coin which is 2x bigger than amount to be spent.
        // Desire to maintain a certain distribution of change to closely match the spending pattern is the best strategy.
        // Yet another strategy is to minimize both current and future spending fees. Thus, keeping number of outputs low and change sum above "dust" threshold.
        
        // For this test we'll just choose the smallest output.
        
        // 1. Sort outputs by amount
        // 2. Find the output that is bigger than what we need and closer to 2x the amount.
        // 3. If not, find a bigger one which covers the amount + reasonably big change (to avoid dust), but as small as possible.
        // 4. If not, find a combination of two outputs closer to 2x amount from the top.
        // 5. If not, find a combination of two outputs closer to 1x amount with enough change.
        // 6. If not, find a combination of three outputs.
        // Maybe Monte Carlo method is a way to go.
        
        // Another way:
        // Find the minimum number of txouts by scanning from the biggest one.
        // Find the maximum number of txouts by scanning from the lowest one.
        // Scan with a minimum window increasing it if needed if no good enough change can be found.
        // Yet another option: finding combinations so the below-the-dust change can go to miners.
        
        var getTxOuts = [BTCTransactionOutput]()
        var total: Int64 = 0
        
        for txout in utxos {
            if txout.script.isPayToPublicKeyHashScript {
                getTxOuts.append(txout)
                total += txout.value
                
                print("txout: \(txout.dictionary)")
            }
            
            if total >= (totalAmount) {
                break
            }
        }
        
        if total < totalAmount {
            return (nil, nil)
        }
        
        let txouts = getTxOuts
        
        //new
        let tx = BTCTransaction()
        tx.fee = fee
        
        var spentCoins = BTCAmount(0)
        
        txouts.forEach { txout in
            let txin = BTCTransactionInput()
            txin.previousHash = txout.transactionHash
            txin.previousIndex = txout.index
            tx.addInput(txin)
            
            spentCoins += txout.value
            
            print("txhash: https://bch.btc.com/\(BTCHexFromData(txout.transactionHash)!)")
            print("txhash: https://bch.btc.com/\(BTCHexFromData(BTCReversedData(txout.transactionHash))!) (reversed)")
        }
        
        print(String(format: "Total satoshis to spend:       %lld", spentCoins))
        print(String(format: "Total satoshis to destination: %lld", Int64(receiveAmount)))
        print(String(format: "Total satoshis to fee:         %lld", fee))
        print(String(format: "Total satoshis to change:      %lld", spentCoins - (Int64(receiveAmount) + fee)))
        
        // Add required outputs - payment and change
        destinationAddressAmounts.forEach { receiver in
            let paymentOutput = BTCTransactionOutput(value: Int64(receiver.amount), address: receiver.bchAddress)
            tx.addOutput(paymentOutput)
        }
        
        let changeOutput = BTCTransactionOutput(value: spentCoins - totalAmount, address: changeAddress)
        
        if changeOutput!.value > 0 {
            tx.addOutput(changeOutput)
        }
        
        for i in 0 ..< txouts.count {
            // Normally, we have to find proper keys to sign this txin, but in this
            // example we already know that we use a single private key.
            
            let txout = txouts[i] // output from a previous tx which is referenced by this txin.
            let txin = tx.inputs[i] as! BTCTransactionInput
            let sigScript = BTCScript()!
            
            let hashType: BTCSignatureHashType = .BCHSignatureHashTypeForkIDAll
            let getHash: Data?
            
            do {
                getHash = try tx.signatureHash(for: txout.script, inputIndex: UInt32(i), hashType: hashType)
            } catch {
                getHash = nil
                errorOut = error
            }
            
            guard let hash = getHash else {
                return (nil, errorOut)
            }
            
            var signatureForScript = key.signature(forHash: hash, hashType: hashType)!
            sigScript.appendData(signatureForScript)
            sigScript.appendData(key.compressedPublicKey as Data)
            
            let sig = signatureForScript[0 ..< signatureForScript.count - 1] // trim hashtype byte to check the signature.
            assert(key.isValidSignature(sig, hash: hash), "Signature must be valid")
            txin.signatureScript = sigScript
        }
        
        // Validate the signatures before returning for extra measure.
        let scriptMachine = BTCScriptMachine(transaction: tx, inputIndex: 0)
        do {
            let script = txouts.first?.script.copy() as! BTCScript
            let result = try scriptMachine?.verify(withOutputScript: script)
            print("self machine verified: \(result!)")
        } catch {
            print("error: \(error)")
            fatalError("verify failed")
        }
        return (tx, errorOut)
    }
}
