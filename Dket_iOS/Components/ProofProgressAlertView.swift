//
//  ProofProgressAlertView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/16/25.
//
import SwiftUI

struct ProofProgressAlertView: View {
    let title: String
    let message: String    
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(":D")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.dketBlue)
                    .padding(.top, 8)
                
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    Text(message)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 28)
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        }
    }
}

struct ProofFailedAlertView: View {
    let title: String
    let message: String
    let retryButtonTitle: String
    let onRetry: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(8)
                    }
                }
                .padding(.trailing, 4)

                Text(":D")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(.dketBlue)
                    .padding(.top, -8)

                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    Text(message)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)

                Button(action: onRetry) {
                    Text(retryButtonTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.dketBlue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 6)
            }
            .padding(.vertical, 28)
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        }
    }
}
