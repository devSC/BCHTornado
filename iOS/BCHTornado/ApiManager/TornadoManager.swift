//
//  TornadoApiManager.swift
//  HUFUWallet
//
//  Created by Wilson Yuan on 18/04/2018.
//  Copyright © 2018 hufubit. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import enum Result.Result

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJson = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJson, options: .prettyPrinted)
        return prettyData
    } catch {
        return data
    }
}

struct ResponseError: Error, CustomStringConvertible {
    static let jsonMapping = ResponseError(message: "jsonMapping error", code: .jsonMapping)
    
    enum Code: Int {
        case serviceError = 0, httpError = 1
        case timeout = 2, cancelled = 3, unknow = 4
        case invalidParams = 5
        case parseResponseError
        case jsonMapping
    }
    
    let message: String
    let code: Code
    
    var description: String {
        return "errorCode: \(code), message: \(message)"
    }
}

class TornadoApiManager {
    static let `default` = TornadoApiManager()
    private let manager: SessionManager
    private let provider: MoyaProvider<Tornado>
    
    init() {
        //TODO: should refresh the host
        
        manager = SessionManager(
            configuration: URLSessionConfiguration.default,
            delegate: SessionDelegate()
        )
        
        let stubBehavior = MoyaProvider<Tornado>.neverStub
        provider = MoyaProvider<Tornado>(
            stubClosure: stubBehavior,
            manager: manager,
            plugins: [
                NetworkLoggerPlugin(
                    verbose: true, responseDataFormatter: JSONResponseDataFormatter
                ), ]
        )
    }
    
    @discardableResult
    static func request(
        _ target: Tornado,
        callbackQueue: DispatchQueue? = nil,
        progress: Moya.ProgressBlock? = nil,
        success: @escaping (Json) -> Void,
        failure: @escaping (ResponseError) -> Void) -> Cancellable {
        return TornadoApiManager.default.request(
            target,
            callbackQueue: callbackQueue,
            progress: progress,
            success: success,
            failure: failure
        )
    }
    
    @discardableResult
    func request(
        _ target: Tornado,
        callbackQueue: DispatchQueue? = nil,
        progress: Moya.ProgressBlock? = nil,
        success: @escaping (Json) -> Void,
        failure: @escaping (ResponseError) -> Void) -> Cancellable {
        
        return provider.request(target, callbackQueue: callbackQueue, progress: progress, completion: { [weak self] result in
            guard let `self` = self else {
                failure(ResponseError(message: "api manager has been destoryed", code: .unknow))
                return
            }
            switch result {
            case .success(let response):
                let (response, error) = self.handle(moyaResponse: response)
                if let error = error {
                    failure(error)
                }
                else {
                    success(response!)
                }
            case .failure(let error):
                failure(self.transform(moyaError: error).1)
            }
            
        })
    }
}

extension TornadoApiManager {
    func handle(moyaResponse response: Response) -> (Json?, ResponseError?) {
        guard let json = try? Json(response.data) else {
            return (nil, ResponseError(message: "Can't parse respose", code: .parseResponseError) )
        }
        return (json, nil)
    }
    
    func transform(moyaError error: MoyaError) -> (Json?, ResponseError) {
        return (nil, ResponseError(message: error.localizedDescription, code: .unknow))
    }
}
