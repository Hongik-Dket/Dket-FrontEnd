//
//  SectionView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

/// 가로 스크롤 섹션 재사용 뷰
struct EventSectionView<Destination: View>: View {
    let title: String
    let events: [Event]
    let destination: Destination // 전체 보기 페이지
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline).bold()
                Spacer()
                NavigationLink(destination: destination) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(events) { event in
                        NavigationLink {
                            EventDetailView(eventId: event.id)
                        } label: {
                            EventCardView(event: event)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

