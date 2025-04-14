//
//  HostHomeView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//
import SwiftUI

struct HostHomeView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 재사용 가능한 헤더 뷰
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
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<9) { _ in
                            EventCardView()
                        }
                    }
                    .padding(.top, 25)
                }
            }
            
            // 플로팅 버튼
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        // 공연 개최하기 로직
                    } label: {
                        Text("공연 개최하기")
                            .padding(20)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 199/255, green: 255/255, blue: 216/255))
                            .frame(maxWidth: 360, maxHeight: 48)
                            .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                            .cornerRadius(24)
                            .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 4)
                    }
                    Spacer()
                }
                .padding(.bottom, 15)
            }
        }
    }
}

struct HostHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HostHomeView()
    }
}

