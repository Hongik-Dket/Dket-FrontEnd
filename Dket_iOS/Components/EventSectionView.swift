//
//  SectionView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct EventSectionView<Destination: View>: View {
    var title: String
    var destination: Destination

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                    .bold()
                Spacer()
                NavigationLink(destination: destination) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(0..<5) { _ in
                        EventCardView()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

