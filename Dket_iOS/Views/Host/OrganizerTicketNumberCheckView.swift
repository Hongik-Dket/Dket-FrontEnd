//
//  OrganizerTicketNumberCheckView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI


struct OrganizerTicketNumberCheckView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var ticketNumber: String = ""
    @State private var isSearching = false
    @State private var selectedTicket: TicketDetail?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var goToMypage = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    let onDismiss: () -> Void
    let ticketService = TicketService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BackHeaderView(
                    onBack: { dismiss() },
                    onMenu: { goToMypage = true }
                )
                
                Spacer()
                
                ZStack {
                    Image("TicketNumberCheck")
                        .resizable()
                        .frame(width: 350, height: 150)
                        .shadow(radius: 2)
                        .allowsHitTesting(false)
                    
                    Button(action: {
                        isTextFieldFocused = true
                    }) {
                        Color.clear
                    }
                    .frame(width: 350, height: 150)
                    
                    VStack(spacing: 0) {
                        TextField(
                            "",
                            text: $ticketNumber,
                            prompt: Text("티켓 번호를 입력하세요")
                                .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                                .font(.system(size: 16, weight: .medium))
                        )
                        .focused($isTextFieldFocused)
                        .foregroundColor(.dketMint)
                        .font(.system(size: 26, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 24)
                        .frame(width: 297, height: 48)
                        .background(Color.clear)
                        .overlay(
                            Rectangle()
                                .frame(height: 5)
                                .foregroundColor(.dketMint),
                            alignment: .bottom
                        )
                    }
                }
                .padding(.vertical, 40)
                
                if isSearching {
                    ProgressView("조회 중입니다...")
                        .padding(.bottom, 10)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        Task {
                            do {
                                isSearching = true
                                let result = try await ticketService.fetchTicketByNumber(ticketNumber)
                                await MainActor.run {
                                    selectedTicket = result
                                }
                            } catch {
                                await MainActor.run {
                                    errorMessage = "티켓 조회에 실패했습니다. 다시 확인해주세요."
                                    showErrorAlert = true
                                    selectedTicket = nil
                                }
                            }
                            isSearching = false
                        }
                    } label: {
                        Text("티켓 조회하기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 360, maxHeight: 48)
                            .background(ticketNumber.isEmpty ? Color.gray : Color.dketBlue)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                    }
                    .disabled(ticketNumber.isEmpty)
                    
                    Button {
                        dismiss()
                        onDismiss()
                    } label: {
                        Text("QR 코드로 확인하기")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.dketMint)
                            .frame(maxWidth: 360, maxHeight: 48)
                            .background(Color.dketBlue)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                    }
                }
                .padding(.bottom, 40)
                
                NavigationLink(
                    destination: MypageView().environmentObject(appState),
                    isActive: $goToMypage
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .background(Color.white)
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedTicket != nil },
                set: { if !$0 { selectedTicket = nil } }
            )) {
                if let ticket = selectedTicket {
                    OrganizerTicketDetailView(ticket: ticket) {
                        selectedTicket = nil
                        onDismiss()
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("조회 실패"), message: Text(errorMessage), dismissButton: .default(Text("확인")))
            }
        }
    }
}
