//
//  BuyerHomeView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI

/// "구매자 홈" – 서버 데이터와 연결된 최종 화면
struct BuyerHomeView: View {
    @StateObject private var vm = BuyerHomeViewModel()

    @State private var selectedEventId: Int64?
    @State private var selectedListType: ListingType?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    SearchHeaderView(
                        onSearch: { /* TODO */ },
                        onMenu:   { /* TODO */ }
                    )

                    switch vm.state {
                    case .idle, .loading:
                        ProgressView().padding(.top, 60)

                    case .failed(let err):
                        Text(err.localizedDescription)
                            .foregroundColor(.red)
                            .padding(.top, 60)

                    case .loaded:
                        if let bundle = vm.home {
                            EventSectionView(
                                title: "💖 인기 공연",
                                emptyMessage: "응모된 공연이 없습니다",
                                events: bundle.popular,
                                onEventTap: { event in selectedEventId = event.id },
                                onSeeAllTap: { selectedListType = .popular }
                            )

                            EventSectionView(
                                title: "⏳ 응모한 공연",
                                emptyMessage: "응모한 공연이 없습니다",
                                events: bundle.applied,
                                onEventTap: { event in selectedEventId = event.id },
                                onSeeAllTap: { selectedListType = .applied }
                            )

                            EventSectionView(
                                title: "🎟️ 구매한 공연",
                                emptyMessage: "구매한 공연이 없습니다",
                                events: bundle.purchased,
                                onEventTap: { event in selectedEventId = event.id },
                                onSeeAllTap: { selectedListType = .purchased }
                            )

                            EventSectionView(
                                title: "🗒️ 전체 공연",
                                emptyMessage: "공연이 없습니다",
                                events: bundle.entire,
                                onEventTap: { event in selectedEventId = event.id },
                                onSeeAllTap: { selectedListType = .entire }
                            )
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .refreshable { await vm.refresh() }
            
            .task { await vm.onAppear() }

            .navigationDestination(item: $selectedEventId) { eventId in
                BuyerEventDetailView(eventId: eventId)
            }

            .navigationDestination(item: $selectedListType) { type in
                EventListView(type: type)
            }
        }
    }
}

struct BuyerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        BuyerHomeView()
    }
}
