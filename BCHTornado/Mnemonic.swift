//
//  Mnemonic.swift
//  BCHTornado
//
//  Created by Song Xiaofeng on 21/07/2018.
//  Copyright © 2018 hufubit. All rights reserved.
//

import Foundation
import SwifterSwift

class Mnemonic: BTCMnemonic {
    var wordsString: String {
        let words = Mnemonic(passphrase: nil).words as! [String]
        return words.joined(separator: " ")
    }
    
    convenience init(passphrase: String? = nil) {
        let entropy = BTCRandomDataWithLength(16) as Data
        self.init(entropy: entropy, password: passphrase, wordListType: .english)
    }
    
    convenience init?(words: [String], passphrase: String? = nil) {
        self.init(words: words.map { $0.lowercased() }, password: passphrase, wordListType: .english)
    }
    
    static func checkIsValid(_ mnemonic: String?, passphrase: String? = nil) -> Bool {
        let unwrappedwords = mnemonic?.components(separatedBy: " ").map { $0.lowercased() }
        guard let words = unwrappedwords else { return false }
        return Mnemonic(words: words, password: passphrase, wordListType: .english) != nil
    }
    
    static func trim(mnemonic: String) -> String {
        return mnemonic.trimmed.lowercased().components(separatedBy: " ").filter { !$0.isEmpty }.joined(separator: " ")
    }
}
