//
//  TodayEventListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct EventListView: View {
    // 어떤 리스트인지 구분
    let type: ListingType

    @StateObject private var vm: EventListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var didLoad = false

    // ViewModel 주입
    init(type: ListingType) {
        self.type = type
        _vm = StateObject(wrappedValue: EventListViewModel(type: type))
    }

    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let error):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("불러오기 실패")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                // ⬇︎ 두 번째 예시와 동일한 레이아웃
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12, pinnedViews: []) {
                        ForEach(vm.events) { event in
                            NavigationLink {
                                EventDetailView(eventId: event.id)
                            } label: {
                                VerticalEventCardView(event: event)
                                    .padding(.bottom, 10)   // 동일한 패딩
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                }
            }
        }
        .navigationTitle(type.defaultTitle)
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
        // ❗️ onAppear에서 한 번만 로드
        .onAppear {
            if !didLoad {
                didLoad = true
                vm.load()
            }
        }
    }
}
