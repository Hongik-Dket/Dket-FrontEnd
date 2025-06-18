//
//  BuyerHomeView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI

struct BuyerHomeView: View {
    @StateObject private var vm = BuyerHomeViewModel()
    
    @State private var selectedEventId: Int64?
    @State private var selectedListType: ListingType?
    @EnvironmentObject private var appState: AppState
    @State private var showMypage = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    SearchHeaderView(
                        onSearch: { /* TODO */ },
                        onMenu:   { showMypage = true  }
                    )
                    
                    switch vm.state {
                    case .idle, .loading:
                        ProgressView().padding(.top, 60)
                        
                    case .failed(let err):
                        Text(err.localizedDescription)
                            .foregroundColor(.red)
                            .padding(.top, 60)
                        
                    case .loaded:
                        if let bundle = vm.home {
                            EventSectionView(
                                title: {
                                    HStack(spacing: 8) {
                                        Image("Popular")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("인기 공연")
                                            .font(.headline).bold()
                                    }
                                },
                                emptyMessage: "응모된 공연이 없습니다",
                                events: bundle.popular,
                                onEventTap: { event in selectedEventId = event.id },
                                onSeeAllTap: { selectedListType = .popular }
                            )
                            
                            EventSectionView(
                                title: {
                                    HStack(spacing: 8) {
                                        Image("ApplyEvent")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("응모한 공연")
                                            .font(.headline).bold()
                                    }
                                },
                                emptyMessage: "응모한 공연이 없습니다",
                                events: bundle.applied,
                                onEventTap: { event in selectedEventId = event.id },
                                onSeeAllTap: { selectedListType = .applied }
                            )
                            
                            EventSectionView(
                                title: {
                                    HStack(spacing: 8) {
                                        Image("ProgressEvent")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("구매한 공연")
                                            .font(.headline).bold()
                                    }
                                },
                                emptyMessage: "구매한 공연이 없습니다",
                                events: bundle.purchased,
                                onEventTap: { event in selectedEventId = event.id },
                                onSeeAllTap: { selectedListType = .purchased }
                            )
                            
                            EventSectionView(
                                title: {
                                    HStack(spacing: 8) {
                                        Image("AllEvent")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("전체 공연")
                                            .font(.headline).bold()
                                    }
                                },
                                emptyMessage: "공연이 없습니다",
                                events: bundle.entire,
                                onEventTap: { event in selectedEventId = event.id },
                                onSeeAllTap: { selectedListType = .entire }
                            )
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .refreshable { await vm.refresh() }
            
            .task { await vm.onAppear() }
            
            .navigationDestination(item: $selectedEventId) { eventId in
                BuyerEventDetailView(eventId: eventId)
            }
            
            .navigationDestination(item: $selectedListType) { type in
                EventListView(type: type)
            }
        }
        .fullScreenCover(isPresented: $showMypage) {
            MypageView()
                .environmentObject(appState)
        }
    }
}
