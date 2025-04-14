//
//  EventCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/15/25.
//

import SwiftUI

struct EventCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 216)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                )
                .cornerRadius(10)

            HStack {
                Text("공연 이름")
                    .font(.headline)
                Spacer()
                Text("응모 중 (D-10)")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
                    .bold()
            }

            // 장소와 날짜 정보
            VStack(alignment: .leading, spacing: 2) {
                Text("공연 장소")
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text("2025.04.20 ~ 2025.04.21")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
}

struct EventCardView_Previews: PreviewProvider {
    static var previews: some View {
        EventCardView()
    }
}
