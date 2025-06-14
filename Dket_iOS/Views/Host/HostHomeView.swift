//
//  HostHomeView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//
import SwiftUI

/// “개최자 홈” – 서버 데이터와 연결된 최종 화면
struct HostHomeView: View {
    @StateObject private var vm = OrganizerHomeViewModel()
    @State private var isCreating = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        SearchHeaderView(
                            onSearch: { /* TODO */ },
                            onMenu:   { /* TODO */ }
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
                                    title: "오늘 공연",
                                    emptyMessage: "오늘 공연이 없습니다",
                                    events: bundle.today
                                )
                                
                                EventSectionView(
                                    title: "최근 응모 마감 공연",
                                    emptyMessage: "최근 응모 마감 공연이 없습니다",
                                    events: bundle.recentlyClosed
                                )
                                
                                EventSectionView(
                                    title: "개최한 공연",
                                    emptyMessage: "개최한 공연이 없습니다",
                                    events: bundle.all
                                )
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
                
                Button {
                    isCreating = true
                } label: {
                    Text("공연 개최하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 360, maxHeight: 48)
                        .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                        .cornerRadius(24)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 20)
                
                NavigationLink("", destination: EventSetupView(), isActive: $isCreating)
                    .opacity(0)
            }
            .onAppear {
                Task { await vm.onAppear() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .eventCreated)) { _ in
                print("🔄 [HostHomeView] eventCreated 감지 → 새로고침")
                Task { await vm.onAppear() }
            }
        }
    }
}

struct HostHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HostHomeView()
    }
}

