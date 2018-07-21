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
    
    override func initXib() {
        initFromXib(&container)
    }
}
