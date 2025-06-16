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

    init(ticketId: Int64) {
        _vm = StateObject(wrappedValue: PhotoCardDetailViewModel(ticketId: ticketId))
    }

    var body: some View {
        VStack(spacing: 16) {
            BackHeaderView(
                onBack: { dismiss() },
                onMenu: { print("메뉴 클릭") }
            )

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
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .task {
            await vm.fetch()
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showTicket) {
            BuyerTicketDetailView(ticketId: vm.photoCard?.ticketId ?? 0)
        }
    }
}
