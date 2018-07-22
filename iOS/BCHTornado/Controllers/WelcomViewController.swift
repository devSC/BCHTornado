//
//  ViewController.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/21.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

let commonMnemonic = "person muscle liquid chief retire cram suggest advice spend fresh lava soup"

class HomeViewModel: ReceiveViewModel {
    func requestCheckAddress(_ address: String) -> Observable<String?> {
        return requestBalance(address)
            .map { $0.legacyAddress }
            .catchErrorJustReturn(nil)
    }
}

class WelcomViewController: UIViewController {

    @IBOutlet weak var assetDetailView: AssetDetailView!
    @IBOutlet weak var sendButtonTopConstraint: NSLayoutConstraint!
    
    let viewModel = HomeViewModel()
    let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSendButtonTopConstraint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let wallet = Wallet(mnemonic: commonMnemonic)
        NSLog("address: %@", wallet.mainAddress)
        
//        let outputArray = BitboxApi().unspentOutputs(withAddress: "17Qp9DRhgZvEqM9waX88QkGU9g86ABY5uc") as? [BTCTransactionOutput]
        
        var errorOut: Error?
        var unwrappedUtxos: [BTCTransactionOutput]?
        
        do {
            unwrappedUtxos = try BitboxApi().unspentOutputs(withAddress: "17Qp9DRhgZvEqM9waX88QkGU9g86ABY5uc") as? [BTCTransactionOutput]
        } catch {
            errorOut = error
        }
        print("UTXOs for 17Qp9DRhgZvEqM9waX88QkGU9g86ABY5uc: \(String(describing: unwrappedUtxos)) \(String(describing: errorOut))")
        
    }
    
    func updateSendButtonTopConstraint() {
        if WalletManager.default.haveValidWallet {
            assetDetailView.isHidden = false
            sendButtonTopConstraint.constant = 127.5
            fetchRequestBalance()
        }
        else {
            assetDetailView.isHidden = true
            sendButtonTopConstraint.constant = 12
        }
    }

    @IBAction func sendAction(_ sender: Any) {
        if WalletManager.default.haveValidWallet {
            let transferController = TransferViewController.instanceController()
            show(transferController, sender: nil)
        }
        else {
            let importController = ImportViewController.instanceController()
            show(importController, sender: nil)
        }
    }
    
    @IBAction func receiveAction(_ sender: Any) {
        //show alert view
        if let wallet = WalletManager.default.wallets.first {
            requestToJoinGroup(with: UserAddress(name: "Tornado", address: wallet.mainAddress))
        }
        else {
            showAddressAlertController()
        }
    }
    
    func requestToJoinGroup(with address: UserAddress) {
        requestToJoinGroup(with: address) { [weak self] success in
            HUD.hide()
            if success {
                self?.showReceiveController(with: address)
            }
        }
    }
    
    func showReceiveController(with address: UserAddress) {
        guard let receiveController = storyboardController(by: "ReceiveViewController") as? ReceiveViewController else {
            return
        }
        receiveController.address = address
        show(receiveController, sender: nil)
    }
    
    func showAddressAlertController() {
        let alertController = UIAlertController(
            title: "Address",
            message: "Input your name and bch address",
            preferredStyle: .alert)
        
        let nameFieldTag = 2
        alertController.addTextField { textField in
            textField.tag = nameFieldTag
            textField.placeholder = "name"
//            textField.text = "Wilson"
        }
        
        let addressFieldTag = 3
        alertController.addTextField { textField in
            textField.tag = addressFieldTag
            textField.placeholder = "bch address"
//            textField.text = "1Nkt7pcEtdw9DhqvuEU3dPQe7EqAmT4P3y"
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            guard let name = alertController.textFields?.first(where: { $0.tag == nameFieldTag })?.text,
                let address = alertController.textFields?.first(where: { $0.tag == addressFieldTag })?.text else {
                    return
            }
            guard !name.isEmpty else {
                HUD.flash(.label("Please input your name"), delay: 0.8)
                self?.showAddressAlertController()
                return
            }
            guard !address.isEmpty else {
                HUD.flash(.label("Please input your address"), delay: 0.8)
                self?.showAddressAlertController()
                return
            }
            self?.requestToCheckValidAddress(name, address: address)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }

}

extension WelcomViewController {
    func requestToJoinGroup(with address: UserAddress, completationHandle: @escaping (Bool) -> Void) {
        let params = ["name": address.name,
                      "address": address.address]
        TornadoApiManager.default.rx.request(.group)
            .flatMap { _ in TornadoApiManager.default.rx.request(.join(params)) }
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                completationHandle(true)
            }, onError: { _ in
                completationHandle(false)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchRequestBalance() {
        viewModel.address = WalletManager.default.wallets.first!.mainAddress
        assetDetailView.addressLabel.text = viewModel.address
        viewModel.requestBalance()
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] detail in
                self?.assetDetailView.balance = detail.balanceString
            })
            .disposed(by: disposeBag)
    }
    
    func requestToCheckValidAddress(_ name: String, address: String) {
        HUD.show(.progress)
        self.viewModel.requestCheckAddress(address)
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] legacyAddress in
                if let address = legacyAddress {
                    //is valid address
                    self?.requestToJoinGroup(with: UserAddress(name: name, address: address))
                }
                else {
                    HUD.hide()
                    HUD.flash(.label("Incorrect Bitcoin cash address"), delay: 0.8)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension UIViewController {
    func storyboardController(by identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}
