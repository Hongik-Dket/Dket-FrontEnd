//
//  VerticalEventCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/24/25.
//

import SwiftUI

struct VerticalEventCardView: View {
    let event: Event
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 216)
                .cornerRadius(5)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                )
            
            HStack {
                Text(event.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Text(labelForState(event.state))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
            }
            
            Text(event.location)
                .font(.system(size: 12))
                .foregroundColor(.black)
            
            Text(event.dateRange)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        
    }
    
    private func labelForState(_ state: EventState) -> String {
        switch state {
        case .preEnrollment:    return "응모 전"
        case .enrolling:        return "응모 중"
        case .enrollmentClosed: return "응모 마감"
        case .ticketed:         return "예매 완료"
        case .inProgress:       return "공연 중"
        case .finished:         return "공연 종료"
        }
    }
}
