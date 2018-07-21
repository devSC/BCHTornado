//
//  ImportViewController.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/21.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit

class ImportViewController: UIViewController, StoryboardLoadable {

    @IBOutlet weak var textView: UITextView!
    var activity: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = textView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 14, bottom: 20, right: 14)
        
        //test
//        let mnemonic = Mnemonic(passphrase: nil).wordsString
        textView.text = commonMnemonic
    }

    @IBAction func confirmButtonAction(_ sender: Any) {
        //enter
        let wallet = Wallet(mnemonic: textView.text.trimmed)
        WalletManager.default.wallets.append(wallet)
        
        //to transfer controller
        let transferController = TransferViewController.instanceController()
        show(transferController, sender: nil)
    }
    
    private func configureSubview() {
//        activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        activity.hidesWhenStopped = true
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
//        
//        viewModel.isRequestActiveObservable
//            .subscribeOn(MainScheduler.asyncInstance)
//            .bind(to: activity.rx.isAnimating)
//            .disposed(by: disposeBag)
    }

}
