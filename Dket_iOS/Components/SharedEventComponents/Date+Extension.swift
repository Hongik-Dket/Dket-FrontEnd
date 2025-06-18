//
//  Date+Extension.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

extension Date {
    func daysUntil(_ to: Date) -> Int {
        Calendar.current
            .dateComponents([.day], from: self, to: to)
            .day ?? 0
    }
}
