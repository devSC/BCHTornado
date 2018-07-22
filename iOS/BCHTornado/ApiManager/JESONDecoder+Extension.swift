//
//  JESONDecoder+Extension.swift
//  HUFUWallet
//
//  Created by Wilson on 2018/4/18.
//  Copyright © 2018 Hufu inc. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    func decodeAnyData<T>(_ type: T.Type, from data: Any) throws -> T where T: Decodable {
        var unwrappedData = Data()
        if let data = data as? Data {
            unwrappedData = data
        }
        else if let data = data as? [String: Any] {
            unwrappedData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        }
        else if let data = data as? [[String: Any]] {
            unwrappedData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        }
        else {
            fatalError("error format of data ")
        }
        return try decode(type, from: unwrappedData)
    }
}
