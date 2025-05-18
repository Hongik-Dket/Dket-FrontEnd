//
//  HostHomeView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//
import SwiftUI

/// “개최자 홈” – 서버 데이터와 연결된 최종 화면
struct HostHomeView: View {
    
    // ① ViewModel 주입
    @StateObject private var vm = OrganizerHomeViewModel()
    
    // ② “공연 개최하기” 네비게이션 트리거
    @State private var isCreating = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        
                        // ─── 상단 검색/메뉴 헤더 ───
                        SearchHeaderView(
                            onSearch: { /* TODO */ },
                            onMenu:   { /* TODO */ })
                        
                        // ─── 본문 섹션 ───
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
                                  events: bundle.today,
                                  destination: EventListView(type: .today)
                                )

                                // 최근 응모 마감 공연
                                EventSectionView(
                                  title: "최근 응모 마감 공연",
                                  events: bundle.recentlyClosed,
                                  destination: EventListView(type: .closed)
                                )

                                // 전체(개최한) 공연
                                EventSectionView(
                                  title: "개최한 공연",
                                  events: bundle.all,
                                  destination: EventListView(type: .all)
                                )
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
                
                // ─── 플로팅 “공연 개최하기” 버튼 ───
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
                
                // 숨김용 NavigationLink
                NavigationLink("", destination: EventSetupView(), isActive: $isCreating)
                    .opacity(0)
            }
            // ③ 첫 진입 시 API 호출
            .task { await vm.onAppear() }
        }
    }
}

struct HostHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HostHomeView()
    }
}

