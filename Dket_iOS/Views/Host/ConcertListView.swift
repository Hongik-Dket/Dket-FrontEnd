//
//  TodayEventListView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/16/25.
//

import SwiftUI

struct ConcertListView: View {
    let type: ListingType
    
    @StateObject private var vm: ConcertListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var didLoad = false
    
    init(type: ListingType) {
        self.type = type
        _vm = StateObject(wrappedValue: ConcertListViewModel(type: type))
    }
    
    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .failed(let error):
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("불러오기 실패")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded:
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12, pinnedViews: []) {
                        ForEach(vm.concerts) { concert in
                            NavigationLink {
                                if type.isBuyerList {
                                    BuyerConcertDetailView(concertId: concert.id)
                                } else {
                                    ConcertDetailView(concertId: concert.id)
                                }
                            } label: {
                                VerticalConcertCardView(concert: concert)
                                    .padding(.bottom, 10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                }
            }
        }
        .navigationTitle(type.defaultTitle)
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
        
        .onAppear {
            if !didLoad {
                didLoad = true
                vm.load()
            }
        }
    }
}
