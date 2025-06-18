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
            
            HStack {
                Text(event.title)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text(event.status?.label ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.dketBlue)
            }
            
            Text(event.location)
                .font(.system(size: 12))
            Text(dateRangeString)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(width: 382, height: 278)
        .contentShape(Rectangle())
    }
    
    private var dateRangeString: String {
        let fmt = DateFormatter.yyyyDMMDdd
        return "\(fmt.string(from: event.period.lowerBound)) ~ \(fmt.string(from: event.period.upperBound))"
    }
}
