//
//  AssetDetailView.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/22.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit

@IBDesignable class AssetDetailView: XibLoadableView {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
//
    var balance: String? {
        set {
            if let newFloatValue = newValue?.float(),
                let previousValue = balanceLabel.text?.float(),
                newFloatValue != previousValue {
                
                let animation = CATransition()
                animation.isRemovedOnCompletion = true
                animation.duration = 0.2
                animation.subtype = newFloatValue > previousValue ? kCATransitionFromTop : kCATransitionFromBottom
                animation.type = kCATransitionPush
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                balanceLabel.layer.add(animation, forKey: "changeTextTransition")
            }
            balanceLabel.text = newValue
        }
        get {
            return balanceLabel.text
        }
    }
    
    override func initXib() {
        initFromXib(&container)
    }
}
