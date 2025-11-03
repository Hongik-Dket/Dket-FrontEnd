//
//  SignUpView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/3/25.
//

import SwiftUI

struct SignUpNationalityView: View {
    @State private var goToKoreanSignUp = false
    @State private var goToForeignSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - 상단 로고
                Image("Dket")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 112.65)
                    .padding(.top, 287)
                
                Spacer()
                
                // MARK: - 국적 선택 버튼
                VStack(spacing: 10) {
                    Button {
                        goToKoreanSignUp = true
                        print("🇰🇷 한국인 회원가입 클릭")
                    } label: {
                        Text("한국인 (Korean)")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    
                    Button {
                        goToForeignSignUp = true
                        print("🌍 외국인 회원가입 클릭")
                    } label: {
                        Text("외국인 (Foreign)")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                
                // MARK: - Navigation 이동
                NavigationLink(destination: KoreanSignUpView(), isActive: $goToKoreanSignUp) {
                    EmptyView()
                }
//                NavigationLink(destination: ForeignSignUpView(), isActive: $goToForeignSignUp) {
//                    EmptyView()
//                }
            }
        }
    }
}
