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
import SwifterSwift
import PKHUD
import BigInt
import CryptoSwift

class TransferViewModel: ReceiveViewModel {
    
}


class TransferViewController: UITableViewController, StoryboardLoadable {

    let viewModel = TransferViewModel()
    let disposeBag = DisposeBag()
    let wallet: Wallet = WalletManager.default.wallets.first!
    var assetDetail: AssetDetail!
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
    
    @IBAction func sendButtonAction(_ sender: Any) {
        showSendValueAlert()
    }
    
    func showSendValueAlert() {
        let alertController = UIAlertController(
            title: "Transfer amount",
            message: nil,
            preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "amount"
            textField.keyboardType = .decimalPad
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            guard let value = alertController.textFields?.first?.text else {
                return
            }
            guard value.isNumeric else {
                HUD.flash(.label("Please input valid amount"), delay: 0.8)
                self?.showSendValueAlert()
                return
            }
            self?.showSendConfirmAlert(with: value)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showSendConfirmAlert(with amount: String) {
        let addresses = dataSource.map({ $0.address }).joined(separator: "\n")
        let amountValue = wallet.parseToBigUInt(value: amount)
        //average
        let userCount = dataSource.count
        let (averageValue, _) = amountValue.quotientAndRemainder(dividingBy: BigUInt(userCount))
        let averageString = wallet.formatterToUnitString(value: averageValue)
        let alertController = UIAlertController(
            title: "Confirm",
            message: "Are you sure you want to send the \(amount) BCH average to the address below? \n\n\(addresses)\n\n(\(averageString) bitcoin cash/per)",
            preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Sure", style: .default) { [weak self] action in
            //is valid address
            self?.sendPayment(with: amount)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func sendPayment(with amount: String) {
        
        HUD.show(.progress)
        
        let amount = wallet.parseToBigUInt(value: amount)
        //average
        let userCount = dataSource.count
        let (averageValue, _) = amount.quotientAndRemainder(dividingBy: BigUInt(userCount))
        let receivers = dataSource.map { ReceiveInfo(address: $0.address, amount: BigInt(averageValue)) }
        let tx: BTCTransaction
        do {
            tx = try wallet.sign(toValues: receivers)
        } catch {
            print("error: \(error)")
            HUD.flash(.labeledError(title: "Opps... sign transaction error", subtitle: nil), delay: 0.8)
            return
        }
        
        let rawTxData = tx.data.toHexString()
        print(rawTxData)
        
        let request = BitboxApi().requestForTransactionBroadcast(with: tx.data)
        let task = URLSession.shared.dataTask(with: request as! URLRequest) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error.debugDescription)
                    HUD.flash(.labeledError(title: error.debugDescription, subtitle: nil), delay: 0.8)
                }else{
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    print(str ?? "")
                    HUD.flash(.labeledSuccess(title: " Send successfully ", subtitle: str), delay: 0.8)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } as URLSessionTask
        task.resume()
    }
}


extension TransferViewController {
    func startRequestSchedule() {
        viewModel.startRequestSchedule()
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] assetDetail, source in
                self?.assetDetailView.balance = assetDetail.balanceString
                self?.dataSource = source
                self?.assetDetail = assetDetail
                self?.sendButtonEnabled = !source.isEmpty
                self?.title = source.isEmpty ? "Transfer (waiting people...)" : "Transfer"
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
