//
//  ViewController.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/21.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit
import BigInt
import CryptoSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let words = "person muscle liquid chief retire cram suggest advice spend fresh lava soup"
        let wallet = Wallet(mnemonic: words)
        NSLog("address: %@", wallet.mainAddress)
        
//        let outputArray = BitboxApi().unspentOutputs(withAddress: "17Qp9DRhgZvEqM9waX88QkGU9g86ABY5uc") as? [BTCTransactionOutput]
        
        var errorOut: Error?
        var unwrappedUtxos: [BTCTransactionOutput]?
        
        do {
            unwrappedUtxos = try BitboxApi().unspentOutputs(withAddress: "17Qp9DRhgZvEqM9waX88QkGU9g86ABY5uc") as? [BTCTransactionOutput]
        } catch {
            errorOut = error
        }
        print("UTXOs for 17Qp9DRhgZvEqM9waX88QkGU9g86ABY5uc: \(String(describing: unwrappedUtxos)) \(String(describing: errorOut))")
        
        let receiver = ReceiveInfo(address: "1GJZp8GP2i9KBkiaqr1chT1j9XPGPvHf9D", amount: BigInt(100000))
        do {
            let tx = try wallet.sign(toValues: [receiver])
            let rawTxData = tx.data.toHexString()
            print(rawTxData)
        } catch {
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

