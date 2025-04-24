//
//  EventDetailSheet.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/24/25.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height * 0.5
    let minHeight: CGFloat = 80
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    var body: some View {
        ZStack(alignment: .top) {
            // 배너
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                )
            
            // 드래그 가능한 시트
            VStack {
                Capsule()
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                ScrollView {
                    detailContent()
                        .padding()
                }
            }
            .background(Color(red: 22/255, green: 29/255, blue: 111/255))
            .cornerRadius(16)
            .offset(y: sheetOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = sheetOffset + value.translation.height
                        sheetOffset = min(max(newOffset, UIScreen.main.bounds.height - maxHeight), UIScreen.main.bounds.height - minHeight)
                    }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    private func detailContent() -> some View {
        Text(event.name)
            .font(.title2)
            .foregroundColor(.white)
            .padding(.bottom, 12)
        
        Group {
            detailRow("장소", event.location)
            detailRow("기간", event.dateRange)
            // 상태별 추가 필드
            if event.state == .preEnrollment {
                detailRow("응모 시작", "2025.02.21 10:00")
                detailRow("응모 마감", "2025.02.28 16:00")
            }
            // … 나머지 상태별 분기
            detailRow("상태", event.state.label)
        }
        .foregroundColor(.white)
        .font(.body)
    }
    
    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(value)
        }
    }
}
