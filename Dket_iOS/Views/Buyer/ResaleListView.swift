//
//  ResaleListView.swift
//  Dket_iOS
//
//  Created by M-136 on 9/30/25.
//

import SwiftUI

struct ResaleListView: View {
    @StateObject var viewModel: ResaleViewModel
    @State private var isDropdownOpen: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // 날짜 선택 커스텀 드롭다운 박스
            VStack(alignment: .leading, spacing: 4) {
                Button(action: {
                    withAnimation {
                        isDropdownOpen.toggle()
                    }
                }) {
                    HStack {
                        Text(viewModel.selectedDate ?? "날짜 선택")
                            .foregroundColor(viewModel.selectedDate == nil ? .gray : .black)
                        Spacer()
                        Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(height: 44)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }

                if isDropdownOpen {
                    VStack(spacing: 0) {
                        ForEach(viewModel.sessionDates, id: \.self) { date in
                            Button(action: {
                                withAnimation {
                                    viewModel.selectDate(date)
                                    isDropdownOpen = false
                                }
                            }) {
                                Text(date)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color.white)
                            .foregroundColor(.black)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                }
            }
            .padding(.horizontal)

            // 티켓 리스트
            if viewModel.isLoading {
                Spacer()
                ProgressView("로딩 중...")
                Spacer()
            } else if viewModel.selectedDate == nil {
                Spacer()
                Text("날짜를 먼저 선택해주세요.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else if viewModel.resaleTickets.isEmpty {
                Spacer()
                Text("판매중인 티켓이 없습니다")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.resaleTickets, id: \.id) { ticket in
                            ResaleTicketCardView(ticket: ticket)
                        }
                    }
                    .padding(.horizontal)
                }
            }

        }
        .navigationTitle("공연명")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResaleListView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTickets = [
            ResaleTicket(
                id: 1,
                price: 226800,
                seatNumber: 39,
                isAvailable: true,
                photoCardURL: nil
            ),
            ResaleTicket(
                id: 2,
                price: 226800,
                seatNumber: 41,
                isAvailable: true,
                photoCardURL: nil
            ),
            ResaleTicket(
                id: 3,
                price: 226800,
                seatNumber: 11,
                isAvailable: false,
                photoCardURL: nil
            )
        ]

        let sessionDates = ["2025-08-16", "2025-08-17"]
        let sessionIdMap: [String: Int64] = ["2025-08-16": 101, "2025-08-17": 102]

        let mockViewModel = ResaleViewModel(sessionDates: sessionDates, sessionIdMap: sessionIdMap)
        mockViewModel.selectedDate = "2025-08-16"
        mockViewModel.resaleTickets = sampleTickets
        mockViewModel.isLoading = false

        return NavigationStack {
            ResaleListView(viewModel: mockViewModel)
        }
    }
}
