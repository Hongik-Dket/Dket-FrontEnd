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
    
    @State private var showMyTickets = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    BackHeaderView(onBack: { dismiss() }, onMenu: {})
                    
                    Divider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 40) {
                            MypageRow(title: "내 지갑 정보") {
                                print("지갑 정보")
                            }
                            
                            if appState.userRole == .buyer {
                                MypageRow(title: "MY 티켓") {
                                    showMyTickets = true
                                }
                                
                                MypageRow(title: "MY 포토카드") {
                                    print("포토카드")
                                }
                            }
                            
                            MypageRow(title: "로그아웃") {
                                print("로그아웃")
                            }
                            
                            MypageRow(title: "서비스 탈퇴") {
                                print("탈퇴")
                            }
                            
                            MypageRow(title: "이용약관") {
                                print("약관")
                            }
                            
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
                
                NavigationLink("", destination: TicketListView(), isActive: $showMyTickets)
                    .opacity(0)
            }
            .navigationBarHidden(true)
        }
    }
}

