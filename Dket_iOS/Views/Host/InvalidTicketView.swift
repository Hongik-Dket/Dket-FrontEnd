//
//  InvalidTicketView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/15/25.
//

import SwiftUI

struct InvalidTicketView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Image("TicketDetail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding(20)
                    }
                }
                .padding(.trailing, 16)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .foregroundColor(Color.dketBlue)
                    
                    Text("이미 입장했거나,\n유효하지 않은 티켓입니다.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.bottom, 40)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("다른 티켓 확인하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 360, maxHeight: 48)
                        .background(Color.dketBlue)
                        .cornerRadius(24)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 60)
            }
        }
    }
}


