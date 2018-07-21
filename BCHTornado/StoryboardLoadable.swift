//
//  Storyboardable.swift
//  BCHTornado
//
//  Created by Wilson on 2018/7/21.
//  Copyright © 2018 hufubit. All rights reserved.
//

import UIKit

protocol StoryboardLoadable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle { get }
}

extension StoryboardLoadable where Self: UIViewController {
    
    static var storyboardName: String {
        return "Main"
    }
    
    static var storyboardBundle: Bundle {
        return Bundle.main;
    }
    
    static func instanceController() -> Self {
        
        assert(storyboardName.isEmpty == false, "storyboard name can't be nil")
        
        let controller = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
            .instantiateViewController(withIdentifier: Self.className)
        
        if controller is Self {
            debugPrint("storyboard controller: \(controller)");
        }
        else {
            fatalError("controller must be current type")
        }
        return controller as! Self;
    }
}

extension NSObject {
    public var className: String {
        return type(of: self).className
    }
    
    public static var className: String {
        return String(describing: self)
    }
}


