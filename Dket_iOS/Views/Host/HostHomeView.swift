//
//  HostHomeView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//
import SwiftUI

struct HostHomeView: View {
    // 공연 개최하기 버튼 클릭 시
    @State private var isCreating = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        // 상단 헤더
                        SearchHeaderView(
                            onSearch: {
                                print("Search tapped")
                                // 검색 화면 이동 로직
                            },
                            onMenu: {
                                print("Menu tapped")
                                // 메뉴 열기 로직
                            }
                        )
                        
                        EventSectionView(
                            title: "오늘 공연",
                            events: MockEventData.today,
                            destination: TodayEventListView(events: MockEventData.today)
                        )
                        EventSectionView(
                            title: "최근 응모 마감 공연",
                            events: MockEventData.closed,
                            destination: TodayEventListView(events: MockEventData.closed)
                        )
                        EventSectionView(
                            title: "개최한 공연",
                            events: MockEventData.hosted,
                            destination: TodayEventListView(events: MockEventData.hosted)
                        )
                    }
                    .padding(.bottom, 80)
                }
                
                // 플로팅 버튼
                Button(action: {
                    // 공연 개최하기 액션
                    isCreating = true
                }) {
                    Text("공연 개최하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 360, maxHeight: 48)
                        .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                        .cornerRadius(24)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 20)
                // ③ 실제 네비게이션 처리
                NavigationLink(
                    destination: EventSetupView(),
                    isActive: $isCreating
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}

struct HostHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HostHomeView()
    }
}

