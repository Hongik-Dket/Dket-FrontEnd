//
//  RoleSelectionView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/14/25.
//

import SwiftUI

struct RoleSelectionView: View {
    var body: some View {
        VStack {
            // DKet 로고 이미지
            Image("Dket")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 112.65)
                .padding(.top, 287)
            
            Spacer()
            
            VStack {
                Button {
                    // 개최자 선택
                } label: {
                    Text("개최자")
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                .foregroundColor(.white)
                .cornerRadius(5)
                .padding(.horizontal,30)
        
                Button {
                    // 구매자 선택
                } label: {
                    Text("구매자")
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                .foregroundColor(.white)
                .cornerRadius(5)
                .padding(.horizontal,30)
                .padding(.top, 10)
            }
            .padding(.bottom, 30)
        }
    }
}


struct RoleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RoleSelectionView()
    }
}
