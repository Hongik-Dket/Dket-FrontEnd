//
//  SectionView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct EventSectionView<Title: View>: View {
    let title: Title
    let emptyMessage: String
    let events: [Event]
    
    var onEventTap: ((Event) -> Void)? = nil
    var onSeeAllTap: (() -> Void)? = nil
    var type: ListingType? = nil
    
    init(
        @ViewBuilder title: () -> Title,
        emptyMessage: String,
        events: [Event],
        onEventTap: ((Event) -> Void)? = nil,
        onSeeAllTap: (() -> Void)? = nil,
        type: ListingType? = nil
    ) {
        self.title = title()
        self.emptyMessage = emptyMessage
        self.events = events
        self.onEventTap = onEventTap
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
            
            if events.isEmpty {
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
                        ForEach(events) { event in
                            if let onEventTap {
                                Button {
                                    onEventTap(event)
                                } label: {
                                    EventCardView(event: event)
                                }
                                .buttonStyle(.plain)
                            } else {
                                NavigationLink {
                                    EventDetailView(eventId: event.id)
                                } label: {
                                    EventCardView(event: event)
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
