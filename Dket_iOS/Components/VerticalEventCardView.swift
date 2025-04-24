//
//  VerticalEventCardView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/24/25.
//

import SwiftUI

struct VerticalEventCardView: View {
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
                Text("공연 이름")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("응모 마감")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 22/255, green: 29/255, blue: 111/255))
            }
            
            Text("공연 장소")
                .font(.system(size: 13))
            
            Text("2025.03.20 ~ 2025.03.21")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        
    }
}
