//
//  HostedEventListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct HostedEventListView: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<10) { _ in
                    EventCardView()
                        .padding(.bottom, 10)
                }
            }
            .padding()
        }
        .navigationTitle("개최한 공연")
    }
}
