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
    @State private var showMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 드롭다운 메뉴
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
            
            Divider()
                .padding(.vertical, 8)
            
            // MARK: - 본문 리스트
            Group {
                if vm.isLoading {
                    ProgressView("불러오는 중...")
                        .frame(maxHeight: .infinity)
                } else if let error = vm.errorMessage {
                    Text("⚠️ \(error)")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else if vm.resaleTickets.isEmpty {
                    Text("등록된 리세일 티켓이 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.resaleTickets) { ticket in
                                ResaleTicketCardView(ticket: ticket, basePrice: basePrice)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
            .animation(.easeInOut, value: vm.resaleTickets)
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
    }
    
    // MARK: - 날짜 포맷 함수
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

