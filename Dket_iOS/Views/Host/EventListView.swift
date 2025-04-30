//
//  TodayEventListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

/// “전체 보기” 를 담당하는 공통 리스트 뷰
///
/// - title  : 내비게이션 제목으로 사용
/// - events : 이미 로드된 Domain 모델 배열
struct EventListView: View {
    
    // MARK: – public inits
    let title: String
    let events: [Event]
    
    // 뒤로가기 제어용
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12, pinnedViews: []) {
                ForEach(events) { event in
                    NavigationLink {
                        EventDetailView(eventId: event.id)
                    } label: {
                        VerticalEventCardView(event: event)
                            .padding(.bottom, 10)
                    }
                    .buttonStyle(.plain)      // 카드 눌림 효과 제거
                }
            }
            .padding(.horizontal)
            .padding(.top, 30)
        }
        .navigationTitle(title)              // ← 전달 받은 제목 사용
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
