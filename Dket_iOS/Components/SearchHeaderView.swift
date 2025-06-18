//
//  SearchHeaderView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/15/25.
//

import SwiftUI

struct SearchHeaderView: View {
    var onSearch: () -> Void
    var onMenu: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Image("Dket")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40.38)
            
            Spacer()
            
            Button(action: onMenu) {
                Image(systemName: "line.horizontal.3")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(Color.white)
    }
}
