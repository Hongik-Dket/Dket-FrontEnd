//
//  StepIndicatorView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI

struct StepIndicatorView: View {
    let current: ConcertSetupView.Step
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                stepItem("STEP 1", isActive: current == .one)
                stepItem("STEP 2", isActive: current == .two)
                stepItem("STEP 3", isActive: current == .three)
            }
            .frame(height: 40) // 피그마 기준 높이 40 고정
            .frame(maxWidth: .infinity)
            
            // 하단 구분선 (피그마 디자인에 있는 라인)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3))
        }
    }
    
    private func stepItem(_ text: String, isActive: Bool) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .bold)) // 폰트 사이즈 16 (피그마 Text Small 참고)
            .foregroundColor(
                isActive
                ? Color.dketBlue // 활성 상태: 진한 브랜드 컬러 (글자)
                : Color.gray.opacity(0.5) // 비활성 상태: 연한 회색 (글자)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 꽉 채우기 (흔들림 방지 핵심)
            .background(
                isActive
                ? Color.dketBlue.opacity(0.15) // 활성 상태: 연한 배경색 (투명도 조절)
                : Color.clear // 비활성 상태: 투명
            )
            .contentShape(Rectangle()) // 터치 영역 확보
    }
}
