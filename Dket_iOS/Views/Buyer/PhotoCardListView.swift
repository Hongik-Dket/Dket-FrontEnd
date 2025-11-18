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
    
    @State private var selectedTicketId: Int64? = nil
    @State private var showDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            TicketListHeaderView(
                title: "MY 포토카드",
                onBack: { dismiss() },
                onMenu: onMenu
            )
            
            // 콘텐츠
            Group {
                if vm.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("포토카드를 불러오는 중입니다...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 120)
                    Spacer()
                    
                } else if let error = vm.errorMessage {
                    VStack(spacing: 8) {
                        Text("⚠️ \(error)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                        Button("다시 시도하기") {
                            Task { await vm.fetchCards() }
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.dketBlue)
                    }
                    .padding(.top, 100)
                    Spacer()
                    
                } else if vm.cards.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .frame(width: 50, height: 40)
                            .foregroundColor(.gray.opacity(0.5))
                        Text("아직 등록된 포토카드가 없습니다.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 100)
                    Spacer()
                    
                } else {
                    // ✅ 포토카드 그리드
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 20
                        ) {
                            ForEach(vm.cards) { card in
                                Button {
                                    // ✅ 1프레임 지연을 줘서 값 설정 후 시트 표시
                                    DispatchQueue.main.async {
                                        selectedTicketId = card.ticketId
                                        showDetail = true
                                    }
                                } label: {
                                    AsyncImage(url: URL(string: card.imageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 160, height: 246)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(
                                        color: .black.opacity(0.1),
                                        radius: 3, x: 0, y: 1
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            Task { await vm.fetchCards() }
        }
        // ✅ 시트 대신 전체 화면으로 BuyerTicketDetailView 표시
        .fullScreenCover(isPresented: $showDetail) {
            BuyerTicketDetailWrapper(ticketId: selectedTicketId)
                .ignoresSafeArea()
        }
    }
}

// MARK: - 안전한 Detail Wrapper
/// 시트 표시 시 selectedTicketId가 nil인 경우에도 안전하게 처리
struct BuyerTicketDetailWrapper: View {
    let ticketId: Int64?
    
    var body: some View {
        if let id = ticketId {
            BuyerTicketDetailView(ticketId: id)
        } else {
            Color.white // nil일 때 깜박임 방지
        }
    }
}
