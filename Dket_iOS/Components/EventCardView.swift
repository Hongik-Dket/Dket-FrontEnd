//
//  EventCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

// 섹션 안에 들어가는 공연이미지와 정보.
import SwiftUI

struct EventCardView: View {
    let event: Event
    
    // MARK: View-Constants
    private let thumbSize = CGSize(width: 140, height: 170)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // ① 썸네일 – 네트워크 이미지
            AsyncImage(url: event.bannerURL) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                       .scaledToFill()
                default:
                    // 로딩·실패 공통 플레이스홀더
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(width: thumbSize.width, height: thumbSize.height)
            .clipped()
            .cornerRadius(6)
            
            // ② 텍스트 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)                 // 공연명
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                
                Text(event.location)              // 장소
                    .font(.system(size: 10))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(dateRangeString)             // 기간
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: thumbSize.width)
    }
    
    // MARK: Helper (날짜범위 → “yyyy.MM.dd ~ …”)
    private var dateRangeString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd"
        return "\(fmt.string(from: event.period.lowerBound))"
             + " ~ "
             + "\(fmt.string(from: event.period.upperBound))"
    }
}
