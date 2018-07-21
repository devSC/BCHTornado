//
//  Json.swift
//  HUFUWallet
//
//  Created by Wilson on 2018/4/18.
//  Copyright © 2018 hufubit. All rights reserved.
//

import Foundation

class Json {
    
    enum JsonError: Error {
        case message(String)
    }
    
    private (set) var jsonObj: Any
    
    init(_ object: Any) {
        jsonObj = object
    }
    
    convenience init(_ jsonData: Data) throws {
        let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        self.init(jsonObj)
    }
    
    convenience init(_ jsonString: String) throws {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw JsonError.message("can't get data from giving string")
        }
        try self.init(jsonData)
    }
    
    //////////////////////////////////////////////////////
    func hasValue(forKey key: String) -> Bool {
        guard let dicJson = jsonObj as? [String: Any] else {
            return false
        }
        return dicJson[key] != nil
    }
    
    //////////////////////////////////////////////////////
    func hasValue(at index: Int) -> Bool {
        guard let array = jsonObj as? [Any] else { return false }
        return index < array.count
    }
    
    //////////////////////////////////////////////////////
    /**
     * @return return json raw string
     */
    func stringJson() -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
    
    //////////////////////////////////////////////////////
    func description() -> String? {
        guard let descriptable = jsonObj as? CustomStringConvertible else {
            return nil
        }
        return descriptable.description
    }
    
    //////////////////////////////////////////////////////
    /**
     * @return count of
     */
    func count() -> Int {
        guard let array = jsonObj as? [Any] else {
            return 0
        }
        return array.count
    }
    
    //////////////////////////////////////////////////////
    func originValue(forKey key: String) -> Any? {
        guard let dicJson = jsonObj as? [String: Any] else {
            return false
        }
        return dicJson[key]
    }
    
    //////////////////////////////////////////////////////
    func json(forKey key: String) -> Json? {
        guard let value = originValue(forKey: key) else {
            return nil
        }
        if (value is [AnyHashable: Any]) || (value is [Any]) {
            return Json(value)
        }
        return nil
    }
    
    //////////////////////////////////////////////////////
    /**
     * retrieve string value for key
     *
     * @param key
     * @param defaultStr
     */
    func stringValue(forKey key: String, defaultValue defaultStr: String? = nil) -> String? {
        guard let value = originValue(forKey: key) else {
            return defaultStr
        }
        if value is String {
            return value as? String
        } else if value is CustomStringConvertible {
            return (value as? CustomStringConvertible)?.description
        } else {
            return defaultStr
        }
    }
    
//    //////////////////////////////////////////////////////
//    func integerValue(forKey key: String?, defaultValue defaultInt: Int = 0) -> Int {
//        let value = originValue(forKey: key)
//        if value {
//            return Int(value ?? 0)
//        } else {
//            return defaultInt
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func unsignedIntegerValue(forKey key: String?) -> Int {
//        return unsignedIntegerValue(forKey: key, defaultValue: 0)
//    }
//
//    func unsignedIntegerValue(forKey key: String?, defaultValue defaultInt: Int) -> Int {
//        let value: Int = integerValue(forKey: key, defaultValue: defaultInt)
//        if value >= 0 {
//            return NSUInteger
//        } else {
//            return defaultInt
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func intValue(forKey key: String?) -> Int {
//        return intValue(forKey: key, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func intValue(forKey key: String?, defaultValue defaultInt: Int) -> Int {
//        let value = originValue(forKey: key)
//        if value?.responds(to: #selector(self.intValue)) ?? false {
//            return Int(value ?? 0)
//        } else {
//            return defaultInt
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func charValue(forKey key: String?) -> Int8 {
//        return Int8(integerValue(forKey: key, defaultValue: 0))
//    }
//
//    //////////////////////////////////////////////////////
//    func charValue(forKey key: String?, defaultValue defaultChar: Int) -> Int {
//        let value = originValue(forKey: key)
//        if value?.responds(to: #selector(self.charValue)) ?? false {
//            return Int(Int8(value ?? 0))
//        } else {
//            return defaultChar
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func longValue(forKey key: String?) -> Int {
//        return longValue(forKey: key, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func longValue(forKey key: String?, defaultValue defaultLong: Int) -> Int {
//        let value = originValue(forKey: key)
//        if value?.responds(to: #selector(self.longValue)) ?? false {
//            return Int(value ?? 0)
//        } else {
//            return defaultLong
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func longlongValue(forKey key: String?) -> Int64 {
//        return longlongValue(forKey: key, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func longlongValue(forKey key: String?, defaultValue defaultLonglong: Int64) -> Int64 {
//        let value = originValue(forKey: key)
//        if value?.responds(to: #selector(self.longLongValue)) ?? false {
//            return Int64(value ?? 0)
//        } else {
//            return defaultLonglong
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func doubleValue(forKey key: String?) -> Double {
//        return doubleValue(forKey: key, defaultValue: 0.0)
//    }
//
//    //////////////////////////////////////////////////////
//    func doubleValue(forKey key: String?, defaultValue defaultDouble: Double) -> Double {
//        let value = originValue(forKey: key)
//        if value?.responds(to: #selector(self.doubleValue)) ?? false {
//            return Double(value ?? 0.0)
//        } else {
//            return 0
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func floatValue(forKey key: String?) -> Float {
//        return floatValue(forKey: key, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func floatValue(forKey key: String?, defaultValue defaultFloat: Float) -> Float {
//        let value = originValue(forKey: key)
//        if value?.responds(to: #selector(self.floatValue)) ?? false {
//            return Float(value ?? 0.0)
//        } else {
//            return defaultFloat
//        }
//    }
//
//    //  The converted code is limited to 4 KB.
//    //  Upgrade your plan to remove this limitation.
//    //
//    //////////////////////////////////////////////////////
//
//    func charValue(at index: Int) -> Int8 {
//        return Int8(integerValue(at: index, defaultValue: 0))
//    }
//
//    //////////////////////////////////////////////////////
//    func charValue(at index: Int, defaultValue defaultChar: Int8) -> Int8 {
//        let value = originValue(at: index)
//        if value?.responds(to: #selector(self.charValue)) ?? false {
//            return Int8(value ?? 0)
//        }
//        return defaultChar
//    }
//
//    //////////////////////////////////////////////////////
//    func booleanValue(forKey key: String?) -> Bool {
//        return booleanValue(forKey: key, defaultValue: false)
//    }
//
//    //////////////////////////////////////////////////////
//    func booleanValue(forKey key: String?, defaultValue defaultBoolean: Bool) -> Bool {
//        let value = stringValue(forKey: key, defaultValue: nil)
//        if value != "" {
//            return Bool(value) ?? false
//        }
//        return defaultBoolean
//    }
//
//    //////////////////////////////////////////////////////
//    func json(at index: Int) -> Json? {
//        let value = originValue(at: index)
//        if (value is [AnyHashable: Any]) || (value is [Any]) {
//            return Json(object: value)
//        }
//        return nil
//    }
//
//    //////////////////////////////////////////////////////
//    func originValue(at index: Int) -> Any? {
//        if jsonObj && (jsonObj is [Any]) && index < jsonObj.count() {
//            return jsonObj as? [Any]?[index]
//        }
//        return nil
//    }
//
//    //////////////////////////////////////////////////////
//    func stringValue(at index: Int) -> String? {
//        return stringValue(at: index, defaultValue: nil)
//    }
//
//    //////////////////////////////////////////////////////
//    func stringValue(at index: Int, defaultValue defaultStr: String?) -> String? {
//        let value = originValue(at: index)
//        if (value is String) {
//            return value as? String
//        } else if value?.responds(to: #selector(self.stringValue)) ?? false {
//            return "\((value as? String ?? ""))"
//        } else {
//            return defaultStr
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func intValue(at index: Int) -> Int {
//        return intValue(at: index, defaultValue: 0)
//    }
//
//    func intValue(at index: Int, defaultValue defaultInt: Int) -> Int {
//        let value = originValue(at: index)
//        if value?.responds(to: #selector(self.intValue)) ?? false {
//            return Int(value ?? 0)
//        }
//        return defaultInt
//    }
//
//    func integerValue(at index: Int) -> Int {
//        return integerValue(at: index, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func integerValue(at index: Int, defaultValue defaultInt: Int) -> Int {
//        let value = originValue(at: index)
//        if value?.responds(to: #selector(self.integerValue)) ?? false {
//            return Int(value ?? 0)
//        }
//        return defaultInt
//    }
//
//    //////////////////////////////////////////////////////
//    func longValue(at index: Int) -> Int {
//        return longValue(at: index, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func longValue(at index: Int, defaultValue defaultLong: Int) -> Int {
//        let value = originValue(at: index)
//        if value?.responds(to: #selector(self.longValue)) ?? false {
//            return Int(value ?? 0)
//        }
//        return defaultLong
//    }
//
//    //////////////////////////////////////////////////////
//    func longlongValue(at index: Int) -> Int64 {
//        return longlongValue(at: index, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func longlongValue(at index: Int, defaultValue defaultLonglong: Int64) -> Int64 {
//        let value = originValue(at: index)
//        if value?.responds(to: #selector(self.longLongValue)) ?? false {
//            return Int64(value ?? 0)
//        } else {
//            return defaultLonglong
//        }
//    }
//
//    //////////////////////////////////////////////////////
//    func doubleValue(at index: Int) -> Double {
//        return doubleValue(at: index, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func doubleValue(at index: Int, defaultValue defaultDouble: Double) -> Double {
//        let value = originValue(at: index)
//        if value?.responds(to: #selector(self.doubleValue)) ?? false {
//            return Double(value ?? 0.0)
//        }
//        return defaultDouble
//    }
//
//    //////////////////////////////////////////////////////
//    func floatValue(at index: Int) -> Float {
//        return floatValue(at: index, defaultValue: 0)
//    }
//
//    //////////////////////////////////////////////////////
//    func floatValue(at index: Int, defaultValue defaultFloat: Float) -> Float {
//        let value = originValue(at: index)
//        if value?.responds(to: #selector(self.floatValue)) ?? false {
//            return Float(value ?? 0.0)
//        }
//        return defaultFloat
//    }
//
//    //////////////////////////////////////////////////////
//    func copy(with zone: NSZone? = nil) -> Any {
//        var copyJson: Json? = nil
//        if let aZone = jsonObj.copy(with: zone) as? NSItemProviderWriting {
//            copyJson = type(of: self).init(object: aZone)
//        }
//        if let aJson = copyJson {
//            return aJson
//        }
//        return Json()
//    }
    
}
