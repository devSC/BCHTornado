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
        
        
        
        // 这两个都是我的bitpie地址
        let receiver = ReceiveInfo(address: "1GJZp8GP2i9KBkiaqr1chT1j9XPGPvHf9D", amount: BigInt(100000))
        let receiver2 = ReceiveInfo(address: "1PsvF5hgepvparfSSZTN42ZAq2ne6L9ife", amount: BigInt(100000))
        do {
            let tx = try wallet.sign(toValues: [receiver, receiver2])
            let rawTxData = tx.data.toHexString()
            print(rawTxData)
            
            let request = BitboxApi().requestForTransactionBroadcast(with: tx.data)
            
            let task = URLSession.shared.dataTask(with: request as! URLRequest) { (data, response, error) in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    print(str)
                }
            } as URLSessionTask
            
            // 测试发送可以打开注释
//            task.resume()
        
            
            
            
        } catch {
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

