//
//  Untitled.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import SwiftUI

struct PosterView: View {
    let url: URL
    let status: ConcertStatus

    var body: some View {
        ZStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .grayscale(status == .ended ? 1.0 : 0.0)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay { ProgressView() }
            }

            if status == .ended {
                Color.black.opacity(0.2)
                Image("EndedEvent")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .opacity(0.9)
            }
        }
        .frame(width: 393, height: 524)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
