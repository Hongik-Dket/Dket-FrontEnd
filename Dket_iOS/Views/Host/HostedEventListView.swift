//
//  HostedEventListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct HostedEventListView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(0..<10) { _ in
                    VerticalEventCardView()
                        .padding(.bottom, 10)
                }
            }
            .padding()
        }
        .navigationTitle("개최한 공연")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}
