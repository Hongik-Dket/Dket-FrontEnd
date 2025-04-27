//
//  TodayEventListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct TodayEventListView: View {
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
        .navigationTitle("오늘 공연")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
    }
}
