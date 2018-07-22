//
//  AssetDetail.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/22.
//  Copyright © 2018 hufubit. All rights reserved.
//

import Foundation

struct AssetDetail: Codable {
    let balance: Double
    let balanceSat: Int
    let totalReceived: Double
    let totalReceivedSat: Int
    let totalSent: Double
    let totalSentSat: Int
    let unconfirmedBalance: Double
    let unconfirmedBalanceSat: Int
    let unconfirmedTxApperances: Int
    let txApperances: Int
    let transactions: [String]
    let legacyAddress: String
    let cashAddress: String
}

extension AssetDetail {
    var balanceString: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 8
        return formatter.string(from: NSNumber(value: balance))
    }
}
