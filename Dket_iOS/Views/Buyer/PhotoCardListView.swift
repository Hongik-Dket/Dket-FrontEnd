//
//  PhotoCardListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct PhotoCardListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = PhotoCardListViewModel()
    let onMenu: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TicketListHeaderView(
                    title: "MY 포토카드",
                    onBack: { dismiss() },
                    onMenu: onMenu
                )
                
                if vm.isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text("포토카드를 불러오는 중입니다...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 100)
                    Spacer()
                } else if let error = vm.errorMessage {
                    VStack(spacing: 8) {
                        Text("⚠️ \(error)")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                        Button("다시 시도") {
                            Task { await vm.fetchCards() }
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.dketBlue)
                    }
                    .padding(.top, 80)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(vm.cards) { card in
                                // ✅ BuyerTicketDetailWrapper로 감싸서 빌드 안정화
                                NavigationLink(
                                    destination: AnyView(
                                        BuyerTicketDetailWrapper(ticketId: card.ticketId)
                                    )
                                ) {
                                    AsyncImage(url: URL(string: card.imageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 160, height: 246)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                Task { await vm.fetchCards() }
            }
        }
    }
}

// MARK: - BuyerTicketDetailView 래퍼
/// ⚙️ SwiftUI 빌드 안정화를 위해 destination용 간단한 래퍼 추가
struct BuyerTicketDetailWrapper: View {
    let ticketId: Int64
    
    var body: some View {
        // ✅ AnyView 한 번 더 감싸면 SwiftUI 타입 계산 완전히 차단됨
        AnyView(BuyerTicketDetailView(ticketId: ticketId))
    }
}
