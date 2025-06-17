//
//  QRScannerContainerView.swift
//  Dket_iOS
//
//  Created by 이지우 on 5/6/25.
//

import SwiftUI

struct QRScannerContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showManualEntry = false
    let onScan: (String) -> Void
    let onManualTap: () -> Void
    
    var body: some View {
        ZStack {
            QRScanView(onScan: onScan)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 44)
                .padding(.horizontal, 16)
                
                Spacer()
                
                NavigationLink(
                    destination: OrganizerTicketNumberCheckView {
                        showManualEntry = false
                    },
                    isActive: $showManualEntry
                ) {
                    EmptyView()
                }
                
                Button("티켓 번호로 확인하기") {
                    onManualTap()
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: 360, maxHeight: 48)
                .background(Color(red: 22/255, green: 29/255, blue: 111/255))
                .cornerRadius(24)
                .shadow(radius: 4)
                .padding(.bottom, 20)
            }
        }
    }
}
