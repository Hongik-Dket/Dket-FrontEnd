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

extension Date {
    func formatted(style: Style = .shortKorean) -> String {
        let formatter = DateFormatter()
        switch style {
        case .shortKorean:
            formatter.dateFormat = "M월 d일(E)"
            formatter.locale = Locale(identifier: "ko_KR")
        }
        return formatter.string(from: self)
    }

    enum Style {
        case shortKorean
    }
}
