//
//  BuyerHomeView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI

/// "구매자 홈" – 서버 데이터와 연결된 최종 화면
struct BuyerHomeView: View {

    // ① ViewModel 주입
    @StateObject private var vm = BuyerHomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {

                    // ─── 상단 검색/메뉴 헤더 ───
                    SearchHeaderView(
                        onSearch: { /* TODO */ },
                        onMenu:   { /* TODO */ })

                    // ─── 본문 섹션 ───
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
                                events: bundle.popular,
                                destination: EventListView(type: .popular)
                            )

                            EventSectionView(
                                title: "⏳ 응모한 공연",
                                events: bundle.applied,
                                destination: EventListView(type: .applied)
                            )

                            EventSectionView(
                                title: "🎟️ 구매한 공연",
                                events: bundle.purchased,
                                destination: EventListView(type: .purchased)
                            )

                            EventSectionView(
                                title: "전체 공연",
                                events: bundle.entire,
                                destination: EventListView(type: .entire)
                            )
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .task { await vm.onAppear() }
        }
    }
}

struct BuyerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        BuyerHomeView()
    }
}
