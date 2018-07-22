//
//  ImportViewController.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/21.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit
import PKHUD

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
        #if DEBUG
        textView.text = "b*** a*** c**** d**** e**** f**** h**** g**** o**** p**** e**** g****"
        #endif
    }

    @IBAction func confirmButtonAction(_ sender: Any) {
        //enter
        #if DEBUG
        let mnemonic: String? = commonMnemonic
        #else
        let mnemonic: String? = textView.text
        #endif
        if let mnemonic = mnemonic, Mnemonic.checkIsValid(mnemonic) {
            let wallet = Wallet(mnemonic: mnemonic.trimmed)
            WalletManager.default.wallets.append(wallet)
            
            //to transfer controller
            let transferController = TransferViewController.instanceController()
            show(transferController, sender: nil)
        }
        else {
            HUD.flash(.label("Invalid mnemonic"))
        }
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
