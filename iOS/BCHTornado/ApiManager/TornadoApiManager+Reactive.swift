//
//  TornadoApiManager+Reactive.swift
//  HUFUWallet
//
//  Created by Wilson Yuan on 18/04/2018.
//  Copyright © 2018 hufubit. All rights reserved.
//

import Moya
import RxSwift

extension TornadoApiManager: ReactiveCompatible {}

extension Reactive where Base: TornadoApiManager {
    func request(_ target: Tornado, callbackQueue: DispatchQueue? = nil) -> Observable<Json> {
        return base.reactiveRequest(target, callbackQueue: callbackQueue)
    }
}

extension TornadoApiManager {
    func reactiveRequest(_ target: Tornado, callbackQueue: DispatchQueue? = nil) -> Observable<Json> {
        return Observable.create { [weak self] observer in
            let cancellableToken = self?.request(target, callbackQueue: callbackQueue, success: { response in
                observer.onNext(response)
                observer.onCompleted()
            }, failure: { error in
                observer.onError(error)
            })
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}
