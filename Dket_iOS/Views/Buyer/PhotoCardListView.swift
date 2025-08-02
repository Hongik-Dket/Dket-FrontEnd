//
//  PhotoCardListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct PhotoCardListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = PhotoCardListViewModel()
    
    let onMenu: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            TicketListHeaderView(title: "MY 포토카드", onBack: { dismiss() }, onMenu: onMenu)
            
            if vm.isLoading {
                ProgressView()
                    .padding(.top, 100)
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(vm.cards) { card in
                            AsyncImage(url: URL(string: card.imageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 160, height: 246)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            Task { await vm.fetchCards() }
        }
    }
}
