//
//  XibableView.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/22.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit

protocol XibLoadable {
    func initFromXib(_ xibName: String?, container: inout UIView!)
}

extension XibLoadable where Self: UIView {
    
    func initFromXib(_ container: inout UIView!) {
        initFromXib(nil, container: &container)
    }
    
    func initFromXib(_ xibName: String? = nil, container: inout UIView!) {
        let nib = UINib(nibName: xibName ?? self.className, bundle: Bundle(for: type(of: self)))
        container = nib.instantiate(withOwner: self, options: nil).first as! UIView
        container.frame = bounds
        addSubview(container)
    }
}

class XibLoadableView: UIView, XibLoadable {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initXib()
        
        configureSubview()
        bindSubviewEvent()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initXib()
        
        configureSubview()
        bindSubviewEvent()
    }
    
    func initXib() {
        assert(false, "Must impletion by child class")
    }
    
    func configureSubview() {
        
    }
    
    func bindSubviewEvent() {
        
    }
}

