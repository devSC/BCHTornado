//
//  TornadoAPI.swift
//  HUFUWallet
//
//  Created by Wilson Yuan on 27/03/2018.
//  Copyright © 2018 hufubit. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum Tornado {
    case balance(address: String)
}

extension Tornado: TargetType {
    public var baseURL: URL {
        switch self {
        case .balance:
            return URL(string: "https://rest.bitbox.earth/v1")!
        default:
            return URL(string: "http://http://127.0.0.1/:3000")!
        }
    }
    
    public var path: String {
        switch self {
        case .balance(let address):
            return "/address/details/bitcoincash:\(address)"
        }
    }
    
    public var method: Moya.Method {
//        switch self {
//        case .balance:
//            return .get
//        default:
            return .get
//        }
    }
    
    private var bodyEncoding: URLEncoding {
        return URLEncoding(destination: .httpBody)
    }
    
    private var queryStringEncoding: URLEncoding {
        return URLEncoding(destination: .queryString)
    }
    
    public var task: Task {
        switch self {
//        case .balance(let params):
//             return .requestParameters(parameters: params, encoding: bodyEncoding) //body
            //        case .(let params),
        //            return .requestParameters(parameters: params, encoding: queryStringEncoding) //query string
        default:
            return .requestPlain
        }
    }
    
    public var validate: Bool {
        return true
    }
    
    public var sampleData: Data {
        return "".data(using: .utf8)!
        
    }
    
    public var headers: [String: String]? {
        return nil
    }
}

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

