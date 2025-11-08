//
//  KoreanSignUpView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/3/25.
//

import SwiftUI

import SwiftUI

struct KoreanSignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goToPassVerification = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - Dket 로고 (MetaMaskLoginView와 동일 위치)
                Image("Dket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 112.65)
                    .padding(.top, 287)
                
                Spacer()
                
                // MARK: - PASS로 시작하기 버튼
                Button {
                    print("PASS로 시작하기 버튼 클릭됨")
                    goToPassVerification = true
                } label: {
                    HStack(spacing: 1) {
                        Image("PASS")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 16)
                        
                        Text("로 시작하기")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(red: 230/255, green: 73/255, blue: 69/255)) // #E64945
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 80)
                
                // MARK: - Navigation 이동
                NavigationLink(destination: PassVerificationView(), isActive: $goToPassVerification) {
                    EmptyView()
                }
            }
        }
    }
}

struct PassVerificationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("PASS 본인인증 화면")
                .font(.title2.bold())
            Text("PASS 앱을 통해 본인인증을 진행합니다.")
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.top, 100)
        .navigationTitle("본인인증")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    KoreanSignUpView()
        .previewDisplayName("🇰🇷 Korean Sign Up View")
}
