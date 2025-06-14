//
//  PhotoCardListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

import SwiftUI

struct PhotoCardListView: View {
    let cards: [PhotoCardItem]
    var onBack: () -> Void = {}
    var onMenu: () -> Void = {}
    var onTapCard: (PhotoCardItem) -> Void = { _ in }

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            TicketListHeaderView(title: "MY 포토카드", onBack: onBack, onMenu: onMenu)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(cards) { card in
                        Button {
                            onTapCard(card)
                        } label: {
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
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

struct PhotoCardListView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCardListView(cards: [
            PhotoCardItem(photoCardId: 101, imageUrl: "https://via.placeholder.com/160x246"),
            PhotoCardItem(photoCardId: 102, imageUrl: "https://via.placeholder.com/160x246"),
            PhotoCardItem(photoCardId: 103, imageUrl: "https://via.placeholder.com/160x246"),
            PhotoCardItem(photoCardId: 104, imageUrl: "https://via.placeholder.com/160x246")
        ])
    }
}
