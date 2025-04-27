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
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 140, height: 170)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                )
                .cornerRadius(5)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.name)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)

                Text(event.location)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .foregroundColor(.black)

                Text(event.dateRange)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
    }
}

