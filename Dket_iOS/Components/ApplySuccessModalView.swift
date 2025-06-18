//
//  ApplySuccessModalView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/14/25.
//

import SwiftUI

struct ApplySuccessModalView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // 상단 닫기 버튼만 남김
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }

            Spacer().frame(height: 10)

            Image("DketEmpty")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Text("응모가 완료되었습니다.")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.top, 8)

            Spacer().frame(height: 16)

            Button(action: onDismiss) {
                Text("돌아가기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 48)
                    .background(Color(red: 22/255, green: 29/255, blue: 111/255)) // Dket Blue
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Spacer().frame(height: 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(maxWidth: 300)
        .shadow(radius: 8)
    }
}
