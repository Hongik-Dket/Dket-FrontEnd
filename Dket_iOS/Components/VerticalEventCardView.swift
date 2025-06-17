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
        VStack(alignment: .leading, spacing: 6) {
            
            // 배너 이미지 – 고정 크기
            AsyncImage(url: event.imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 382, height: 216)
                        .overlay(
                            Group {
                                if event.status == .ended {
                                    ZStack {
                                        Color.gray.opacity(0.5)
                                        Image("EndedEvent")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200)
                                    }
                                }
                            }
                        )
                default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 382, height: 216)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        )
                }
            }
            .clipped()
            .cornerRadius(6)

            // 타이틀 + 상태
            HStack {
                Text(event.title)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text(event.status?.label ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
            }

            // 장소 / 날짜
            Text(event.location)
                .font(.system(size: 12))
            Text(dateRangeString)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(width: 382, height: 278)  // 전체 카드 크기 고정
    }

    // MARK: – Helpers
    private var dateRangeString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return "\(fmt.string(from: event.period.lowerBound)) ~ \(fmt.string(from: event.period.upperBound))"
    }
}
