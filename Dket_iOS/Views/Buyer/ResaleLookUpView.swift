//
//  ResaleLookUpView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import SwiftUI

struct ResaleLookUpView: View {
    @StateObject private var vm = ResaleLookUpViewModel()
    
    // 예시 세션 목록 (실제 프로젝트에선 서버나 상위뷰에서 전달받음)
    let sessions: [(id: Int64, date: String)] = [
        (101, "11월 7일 (목) 19:00"),
        (102, "11월 8일 (금) 19:00"),
        (103, "11월 9일 (토) 18:00")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - 세션 날짜 선택
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sessions, id: \.id) { session in
                        Button(action: {
                            vm.selectedSessionId = session.id
                        }) {
                            Text(session.date)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(vm.selectedSessionId == session.id ? Color.dketBlue : Color.gray.opacity(0.2))
                                .foregroundColor(vm.selectedSessionId == session.id ? .white : .black)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            // MARK: - 티켓 리스트
            if vm.isLoading {
                ProgressView("티켓 불러오는 중...")
                    .padding()
            } else if let error = vm.errorMessage {
                Text("오류 발생: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if vm.resaleTickets.isEmpty {
                Text("등록된 리세일 티켓이 없습니다.")
                    .foregroundColor(.gray)
                    .padding(.top, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.resaleTickets) { ticket in
                            ResaleTicketCardView(ticket: ticket)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("리세일 티켓 조회")
    }
}
