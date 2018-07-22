//
//  ReceiveInfo.swift
//  BCHTornado
//
//  Created by Song Xiaofeng on 21/07/2018.
//  Copyright © 2018 hufubit. All rights reserved.
//

import Foundation
import BigInt

class ReceiveInfo {
    let address: String
    let amount: BigInt
    
    var bchAddress: BTCAddress {
        return BTCAddress(string: address)!
    }
    
    required init(address: String, amount: BigInt) {
        self.address = address
        self.amount = amount
    }
}
