//
//  PhotoCardDetailView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/17/25.
//

import SwiftUI

struct PhotoCardDetailView: View {
    @StateObject private var vm: PhotoCardDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showTicket = false
    @State private var showMypage = false
    @EnvironmentObject private var appState: AppState
    
    init(ticketId: Int64) {
        _vm = StateObject(wrappedValue: PhotoCardDetailViewModel(ticketId: ticketId))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                VStack(spacing: 16) {
                    BackHeaderView(
                        onBack: { dismiss() },
                        onMenu: { showMypage = true }
                    )
                    .frame(maxWidth: .infinity)
                    
                    if let photoCard = vm.photoCard {
                        if let url = URL(string: photoCard.imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 350, height: 540)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 280, height: 370)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 16) {
                            CircleButton(title: "티켓 보기") {
                                showTicket = true
                            }
                            CircleButton(title: "NFT 티켓 보러가기") {
                                if let url = URL(string: photoCard.nftUrl) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 40)
                    } else {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
        .task {
            await vm.fetch()
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showTicket) {
            BuyerTicketDetailView(ticketId: vm.photoCard?.ticketId ?? 0)
        }
        .fullScreenCover(isPresented: $showMypage) {
            MypageView()
                .environmentObject(appState)
        }
    }
}
