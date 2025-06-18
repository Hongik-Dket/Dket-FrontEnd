//
//  UIApplication+Extension.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/18/25.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func beginEditing() {

    }
}
