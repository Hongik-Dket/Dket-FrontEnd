//
//  VerticalEventCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/24/25.
//

import SwiftUI

struct VerticalEventCardView: View {
    let event: Event
    
    private let thumbHeight: CGFloat = 216
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // ① 배너 이미지 – iOS15+ AsyncImage
            AsyncImage(url: event.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                default:
                    // 로딩 / 실패 → 회색 플레이스홀더
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(maxWidth: .infinity, minHeight: thumbHeight)
            .clipped()
            .cornerRadius(6)
            
            // ② 타이틀 + 상태
            HStack {
                Text(event.title)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text(event.status?.label ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
            }
            
            // ③ 장소 / 날짜
            Text(event.location)
                .font(.system(size: 12))
            Text(dateRangeString)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
    
    // MARK: – Helpers
    private var dateRangeString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return "\(fmt.string(from: event.period.lowerBound))"
        + " ~ "
        + "\(fmt.string(from: event.period.upperBound))"
    }
}
