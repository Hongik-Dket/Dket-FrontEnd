//
//  PopupFlowView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//
import SwiftUI

struct PopupFlowView: View {
    @Binding var step: Int
    @Binding var isPresented: Bool
    let onComplete: () -> Void
    let viewModel: ConcertSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("DketEmpty")
                .font(.system(size: 60))
            
            Group {
                switch step {
                case 1:
                    Text("응모 마감 후 2일간의 결제 기간이 주어지며,\n기간 내 결제되지 않은 티켓은 선착순 판매로 자동 전환됩니다")
                case 2:
                    Text("공연 개최 후에는\n수정 및 삭제가 불가능합니다")
                default:
                    Text("공연 개최가 완료되었습니다")
                }
            }
            .multilineTextAlignment(.center)
            .font(.system(size: 20, weight: .bold))
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                if step < 3 {
                    if step == 2 {
                        viewModel.createConcert()
                    }
                    step += 1
                } else {
                    isPresented = false
                    onComplete()
                }
            }) {
                Text(step == 1
                     ? "다음으로"
                     : step == 2
                     ? "확인했습니다"
                     : "공연 확인하기")
                .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(PrimaryButtonStyle(filled: true))
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
    }
}
