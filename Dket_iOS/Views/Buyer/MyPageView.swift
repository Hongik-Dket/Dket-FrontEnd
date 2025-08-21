//
//  BuyerMyPageView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct MypageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    @StateObject private var vm = MypageViewModel(service: MypageService())
    
    @State private var showWalletInfo = false
    @State private var showMyTickets = false
    @State private var showMyPhotoCards = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    BackHeaderView(onBack: { dismiss() }, onMenu: {})
                    Divider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 40) {
                            // 지갑 정보 토글
                            MypageRow(title: "내 지갑 정보") {
                                withAnimation {
                                    showWalletInfo.toggle()
                                    if showWalletInfo && vm.walletInfo == nil {
                                        vm.fetchWalletInfo()
                                    }
                                }
                            }
                            
                            // 지갑 정보 UI
                            if showWalletInfo {
                                Group {
                                    if let wallet = vm.walletInfo {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Account:")
                                                .font(.footnote).bold()
                                                .foregroundColor(.gray)
                                            Text(wallet.walletAddress)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                            
                                            HStack(spacing: 4) {
                                                Text("\(wallet.balance, specifier: "%.4f")")
                                                    .font(.headline)
                                                    .foregroundColor(.dketBlue)
                                                Text("SepoliaETH")
                                                    .font(.subheadline)
                                                    .foregroundColor(.dketBlue)
                                                    .bold()
                                            }
                                        }
                                        .padding(12)
                                        .background(Color.gray.opacity(0.05))
                                        .cornerRadius(8)
                                        .padding(.leading, 20)
                                        
                                    } else if vm.isLoading {
                                        ProgressView()
                                            .padding(.leading, 20)
                                    } else if let error = vm.errorMessage {
                                        Text("에러: \(error)")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                            .padding(.leading, 20)
                                    }
                                }
                            }
                            
                            // 구매자 전용 메뉴
                            if appState.userRole == .buyer {
                                MypageRow(title: "MY 티켓") {
                                    showMyTickets = true
                                }
                                
                                MypageRow(title: "MY 포토카드") {
                                    showMyPhotoCards = true
                                }
                            }
                            
                            // 공통 메뉴
                            MypageRow(title: "로그아웃") {
                                print("로그아웃")
                            }
                            
                            MypageRow(title: "서비스 탈퇴") {
                                print("탈퇴")
                            }
                            
                            MypageRow(title: "이용약관") {
                                print("약관")
                            }
                            
                            // 역할 전환
                            if appState.userRole == .buyer {
                                MypageRow(title: "개최자 모드로 전환") {
                                    appState.userRole = .host
                                }
                            } else {
                                MypageRow(title: "구매자 모드로 전환") {
                                    appState.userRole = .buyer
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                    }
                }
                
                // 화면 전환
                NavigationLink("", destination: TicketListView(), isActive: $showMyTickets)
                    .opacity(0)
                
                NavigationLink("", destination: PhotoCardListView(onMenu: {}), isActive: $showMyPhotoCards)
                    .opacity(0)
            }
            .navigationBarHidden(true)
        }
    }
}
