//
//  Untitled.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import SwiftUI

struct PosterView: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay { ProgressView() }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
