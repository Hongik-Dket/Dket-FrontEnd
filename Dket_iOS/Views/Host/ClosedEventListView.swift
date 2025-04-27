//
//  Untitled.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct ClosedEventListView: View {
    let events: [Event]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        VerticalEventCardView(event: event)
                            .padding(.bottom, 10)
                    }
                    .buttonStyle(PlainButtonStyle()) // 기본 버튼 효과 제거 (카드 스타일 유지)
                }
            }
            .padding(.top, 30)
            .padding(.horizontal)
        }
        .navigationTitle("최근 응모 마감 공연")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}
