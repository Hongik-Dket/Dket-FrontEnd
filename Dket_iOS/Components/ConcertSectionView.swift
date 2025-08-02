//
//  SectionView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct ConcertSectionView<Title: View>: View {
    let title: Title
    let emptyMessage: String
    let concerts: [Concert]
    
    var onConcertTap: ((Concert) -> Void)? = nil
    var onSeeAllTap: (() -> Void)? = nil
    var type: ListingType? = nil
    
    init(
        @ViewBuilder title: () -> Title,
        emptyMessage: String,
        concerts: [Concert],
        onConcertTap: ((Concert) -> Void)? = nil,
        onSeeAllTap: (() -> Void)? = nil,
        type: ListingType? = nil
    ) {
        self.title = title()
        self.emptyMessage = emptyMessage
        self.concerts = concerts
        self.onConcertTap = onConcertTap
        self.onSeeAllTap = onSeeAllTap
        self.type = type
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                title 
                Spacer()
                if let onSeeAllTap {
                    Button(action: onSeeAllTap) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            if concerts.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    Text(emptyMessage)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(concerts) { concert in
                            if let onConcertTap {
                                Button {
                                    onConcertTap(concert)
                                } label: {
                                    ConcertCardView(concert: concert)
                                }
                                .buttonStyle(.plain)
                            } else {
                                NavigationLink {
                                    ConcertDetailView(concertId: concert.id)
                                } label: {
                                    ConcertCardView(concert: concert)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
