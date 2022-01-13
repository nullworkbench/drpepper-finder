//
//  Extensions.swift
//  drpepper-finder
//
//  Created by nullworkbench on 2021/04/16.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

// グローバル関数
class Ex {
    
    // MARK: Date型をString型に変換する
    class func dateToString(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        
        return f.string(from: date)
    }
    
    // MARK: 禁止ワード確認
    class func checkRestrictionWord(_ target: String) -> Bool {
        // 禁止ワード
        let restrictionWords = ["fuck", "nigger", "cunt", "死", "しね", "しぬ", "しにたい", "殺", "ころす", "ばか", "馬鹿", "バカ", "あほ", "アホ"]
        
        for word in restrictionWords {
            // 小文字に変換して文字列を検索
            if target.lowercased().contains(word) {
                return true
            }
        }
        return false
    }
}
