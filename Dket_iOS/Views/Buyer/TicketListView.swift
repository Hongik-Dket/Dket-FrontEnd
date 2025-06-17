//
//  TicketListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct TicketListView: View {
    @StateObject private var vm = TicketListViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showErrorAlert = false

    @State private var selectedTicketId: Int64? = nil
    @State private var showTicketDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더
            TicketListHeaderView(
                title: "MY 티켓",
                onBack: { dismiss() },
                onMenu: { print("메뉴 클릭") }
            )

            if vm.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if !vm.tickets.isEmpty {
                ScrollView {
                    VStack(spacing: 13) {
                        ForEach(vm.tickets) { ticket in
                            Button {
                                selectedTicketId = ticket.ticketId
                                showTicketDetail = true
                            } label: {
                                TicketCardView(ticket: ticket)
                            }
                            .buttonStyle(.plain) // 기본 버튼 스타일 제거 (카드처럼 보이게)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            } else {
                Spacer()
                Text("보유한 티켓이 없습니다.")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .task {
            await vm.fetchTickets()
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("오류"),
                message: Text(vm.errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
        .onChange(of: vm.errorMessage) { newValue in
            showErrorAlert = newValue != nil
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showTicketDetail) {
            if let ticketId = selectedTicketId {
                BuyerTicketDetailView(ticketId: ticketId)
            }
        }
    }
}
