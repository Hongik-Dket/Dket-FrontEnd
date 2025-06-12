//
//  Date+Extension.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import Foundation

extension Date {
    /// self부터 to까지 남은 일수를 계산합니다.
    func daysUntil(_ to: Date) -> Int {
        Calendar.current
            .dateComponents([.day], from: self, to: to)
            .day ?? 0
    }
}
