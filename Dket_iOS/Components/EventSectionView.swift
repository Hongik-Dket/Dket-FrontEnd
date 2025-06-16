//
//  SectionView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

/// 가로 스크롤 섹션 재사용 뷰
struct EventSectionView: View {
    let title: String
    let emptyMessage: String
    let events: [Event]

    // 공연 카드 클릭 시: 선택적으로 사용
    var onEventTap: ((Event) -> Void)? = nil

    // 전체 보기 클릭 시: 선택적으로 사용
    var onSeeAllTap: (() -> Void)? = nil
    
    var type: ListingType? = nil

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline).bold()
                Spacer()
                if let onSeeAllTap {
                    Button(action: onSeeAllTap) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)

            if events.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    Text(emptyMessage)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(events) { event in
                            if let onEventTap {
                                Button {
                                    onEventTap(event)
                                } label: {
                                    EventCardView(event: event)
                                }
                                .buttonStyle(.plain)
                            } else {
                                NavigationLink {
                                    EventDetailView(eventId: event.id) // 기본 동작
                                } label: {
                                    EventCardView(event: event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
