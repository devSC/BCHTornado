//
//  ReceiveViewController.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/21.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ReceiveViewModel {
//    var assetDetailObservable: BehaviorRelay<AssetDetail?> = BehaviorRelay(value: nil)
    var address: String!
    let disposeBag = DisposeBag()
    var isRequestActiveObservable = BehaviorRelay(value: false)
    
    func requestBalance() -> Observable<AssetDetail> {
        return TornadoApiManager.default.rx.request(.balance(address: self.address))
            .map { try JSONDecoder().decodeAnyData(AssetDetail.self, from: $0.jsonObj) }
    }
    
    func requestGroupList() -> Observable<[UserAddress]> {
        return TornadoApiManager.default.rx.request(.groupPeople)
            .map { $0.json(forKey: "result") }
            .map { item in
                guard let item = item else { return [] }
                return try JSONDecoder().decodeAnyData([UserAddress].self, from: item.jsonObj)
        }
    }
    
    func startRequestSchedule() -> Observable<(AssetDetail, [UserAddress])> {
        return Observable<Int>.timer(0, period: 3, scheduler: MainScheduler.asyncInstance)
            .do(onNext: { [weak self] _ in
                self?.isRequestActiveObservable.accept(true)
            })
            .flatMap { [weak self] _ -> Observable<(AssetDetail, [UserAddress])> in
                guard let `self` = self else { return Observable.empty() }
                return Observable.zip(self.requestBalance(), self.requestGroupList())
            }
            .do(onNext: { [weak self] _ in
                self?.isRequestActiveObservable.accept(false)
                })
    }
}

class ReceiveViewController: UITableViewController {
    
    let viewModel = ReceiveViewModel()
    var address: UserAddress! {
        didSet {
            viewModel.address = address.address
        }
    }
    let disposeBag = DisposeBag()
    var dataSource: [UserAddress] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var activity: UIActivityIndicatorView!
    @IBOutlet weak var assetDetailView: AssetDetailView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubview()
        startRequestSchedule()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if dataSource.isEmpty {
            return nil
        }
        return "Group users (count: \(dataSource.count))"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressInfoTableCell", for: indexPath) as! AddressInfoTableCell
        let userAddress = dataSource[indexPath.row]
        cell.nameLabel.text = userAddress.name
        cell.addressLabel.text = userAddress.address
        return cell
    }
}

extension ReceiveViewController {
    func startRequestSchedule() {
        viewModel.startRequestSchedule()
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] assetDetail, source in
                self?.assetDetailView.balanceLabel.text = assetDetail.balanceString
                self?.dataSource = source
                }, onError: { [weak self] error in
                self?.activity.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
    
    private func configureSubview() {
        activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
        assetDetailView.addressLabel.text = address.address
        
        viewModel.isRequestActiveObservable
            .subscribeOn(MainScheduler.asyncInstance)
            .bind(to: activity.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}
