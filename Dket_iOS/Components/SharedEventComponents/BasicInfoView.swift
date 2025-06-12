//
//  Untitled.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import SwiftUI

struct BasicInfoView: View {
    let detail: EventDetail
    
    private var periodText: String {
        let df = DateFormatter.yyyyDMMDdd
        return "\(df.string(from: detail.period.lowerBound)) ~ \(df.string(from: detail.period.upperBound))"
    }
    
    private var applyPeriodText: String {
        let df = DateFormatter.yyyyDMMDdd
        return "\(df.string(from: detail.applyPeriod.lowerBound)) ~ \(df.string(from: detail.applyPeriod.upperBound))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(detail.title).font(.title2).bold()
            Text(detail.location).font(.callout).foregroundStyle(.secondary)
            Text(periodText).font(.system(size: 16))
            
            let startTime = DateFormatter.hhmmss.date(from: detail.timeRange.start) ?? Date()
            let endTime = DateFormatter.hhmmss.date(from: detail.timeRange.end) ?? Date()
            Text("\(DateFormatter.HHmm.string(from: startTime)) ~ \(DateFormatter.HHmm.string(from: endTime))")
                .font(.subheadline)
            
            Text(detail.ageLimit.label).font(.footnote)
            Divider().padding(.vertical, 4)
            
            HStack {
                Text("응모 기간"); Spacer(); Text(applyPeriodText)
            }.font(.footnote)
            
            HStack {
                Text("공연 상태"); Spacer(); Text(detail.status.label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
            }.font(.footnote)
            
            HStack {
                Text("관람 인원"); Spacer(); Text("\(detail.capacity)명")
            }.font(.footnote)
            
            HStack {
                Text("가격"); Spacer(); Text("\(detail.priceKrw.formatted()) 원")
            }.font(.footnote)
        }
    }
}
