//
//  EventCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

// 섹션 안에 들어가는 공연이미지와 정보.
import SwiftUI

struct ConcertCardView: View {
    let concert: Concert
    
    private let thumbSize = CGSize(width: 140, height: 170)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            AsyncImage(url: concert.imageUrl) { phase in
                switch phase {
                case .success(let img):
                    img.resizable()
                        .scaledToFill()
                        .overlay(
                            Group {
                                if concert.status == .ended {
                                    ZStack {
                                        Color.gray.opacity(0.5)
                                        Image("EndedEvent")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                            }
                        )
                default:
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
            
            VStack(alignment: .leading, spacing: 2) {
                Text(concert.title)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
                
                Text(concert.location)
                    .font(.system(size: 10))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(dateRangeString)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: thumbSize.width)
    }
    
    private var dateRangeString: String {
        let fmt = DateFormatter.yyyyDMMDdd
        return "\(fmt.string(from: concert.period.lowerBound)) ~ \(fmt.string(from: concert.period.upperBound))"
    }
}
