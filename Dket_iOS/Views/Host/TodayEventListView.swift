//
//  TodayEventListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct TodayEventListView: View {
    let events: [Event]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(events) { event in
                    NavigationLink(value: event) {
                        VerticalEventCardView(event: event)
                            .padding(.bottom, 10)
                    }
                }
            }
            .padding(.top, 30)
            .padding(.horizontal)
        }
        .navigationTitle("오늘 공연")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        
        // NavigationDestination 등록
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event)
        }
    }
}
