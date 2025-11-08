//
//  ResaleLookUpView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import SwiftUI

struct ResaleLookUpView: View {
    let concertId: Int64
    let sessions: [BuyerSessionDetail]      // 상위 뷰에서 전달받음
    let basePrice: Int                      // 공연의 정가 (퍼센트 계산용)
    
    @StateObject private var vm = ResaleLookUpViewModel()
    @State private var selectedSession: BuyerSessionDetail? = nil
    @State private var selectedTicket: ResaleTicket? = nil

    var body: some View {
        VStack(spacing: 0) {
            sessionPickerSection
            Divider().padding(.vertical, 8)
            ticketListSection
        }
        .navigationTitle("리세일 티켓 조회")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // 첫 세션 자동 조회
            if let first = sessions.first {
                selectedSession = first
                await vm.fetchResaleTickets(sessionId: first.id)
            }
        }
        .onAppear {
            Task {
                if let session = selectedSession {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    await vm.fetchResaleTickets(sessionId: session.id)
                }
            }
        }
    }
}

extension ResaleLookUpView {
    // MARK: - 1️⃣ 날짜 선택 드롭다운
    private var sessionPickerSection: some View {
        Menu {
            ForEach(sessions, id: \.id) { session in
                Button {
                    selectedSession = session
                    Task {
                        await vm.fetchResaleTickets(sessionId: session.id)
                    }
                } label: {
                    Text(formattedDate(session.date))
                }
            }
        } label: {
            HStack {
                Text(selectedSession.map { formattedDate($0.date) } ?? "날짜 선택")
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }

    // MARK: - 티켓 리스트 섹션
    private var ticketListSection: some View {
        Group {
            if vm.isLoading {
                loadingView
            } else if let error = vm.errorMessage {
                errorView(error)
            } else if vm.resaleTickets.isEmpty {
                emptyView
            } else {
                ticketScrollView
            }
        }
        .animation(.easeInOut, value: vm.resaleTickets)
    }

    // MARK: - 로딩 상태
    private var loadingView: some View {
        ProgressView("불러오는 중...")
            .frame(maxHeight: .infinity)
    }

    // MARK: - 에러 상태
    private func errorView(_ message: String) -> some View {
        Text("⚠️ \(message)")
            .foregroundColor(.red)
            .padding()
            .frame(maxHeight: .infinity)
    }

    // MARK: - 빈 리스트 상태
    private var emptyView: some View {
        Text("등록된 리세일 티켓이 없습니다.")
            .foregroundColor(.gray)
            .padding()
            .frame(maxHeight: .infinity)
    }

    // MARK: - 실제 티켓 리스트
    private var ticketScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.resaleTickets) { ticket in
                    NavigationLink(
                        destination: ResalePurchaseView(resaleId: ticket.id),
                        tag: ticket,
                        selection: $selectedTicket
                    ) {
                        ResaleTicketCardView(ticket: ticket, basePrice: basePrice)
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTicket = ticket
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 12)
        }
    }

    // MARK: - 날짜 포맷 함수
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
