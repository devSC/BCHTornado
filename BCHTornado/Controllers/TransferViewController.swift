//
//  TransferViewController.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/21.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TransferViewModel: ReceiveViewModel {
    
}


class TransferViewController: UITableViewController, StoryboardLoadable {

    let viewModel = TransferViewModel()
    let disposeBag = DisposeBag()
    let wallet: Wallet = WalletManager.default.wallets.first!
    var dataSource: [UserAddress] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var sendButtonEnabled: Bool {
        set {
            sendButton.isEnabled = newValue
            if newValue {
                sendButton.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
            }
            else {
                sendButton.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 0.7)
            }
        }
        get { return sendButton.isEnabled }
    }
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var assetDetailView: AssetDetailView!
    var activity: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.address = wallet.mainAddress
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendAddressInfoTableCell", for: indexPath) as! SendAddressInfoTableCell
        let userAddress = dataSource[indexPath.row]
        cell.nameLabel.text = userAddress.name
        cell.addressLabel.text = userAddress.address
        return cell
    }

}


extension TransferViewController {
    func startRequestSchedule() {
        viewModel.startRequestSchedule()
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] assetDetail, source in
                self?.assetDetailView.balanceLabel.text = assetDetail.balanceString
                self?.dataSource = source
                self?.sendButtonEnabled = !source.isEmpty
                }, onError: { error in
                    
            })
            .disposed(by: disposeBag)
    }
    
    private func configureSubview() {
        activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
        assetDetailView.addressLabel.text = wallet.mainAddress
        
        viewModel.isRequestActiveObservable
            .subscribeOn(MainScheduler.asyncInstance)
            .bind(to: activity.rx.isAnimating)
            .disposed(by: disposeBag)
        
        navigationController?.viewControllers = (navigationController?.viewControllers.filter { !($0 is ImportViewController) }) ?? []
    }
}
