//
//  EventCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

// 섹션 안에 들어가는 공연이미지와 정보.
import SwiftUI

struct EventCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 180)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                )
                .cornerRadius(10)

            Text("공연 이름")
                .font(.headline)
            Text("공연 장소")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("2025.04.20 ~ 2025.04.21")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 150)
    }
}

