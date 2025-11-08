//
//  EntryCodeView.swift
//  Dket_iOS
//
//  Created by M-136 on 11/7/25.
//

import SwiftUI

struct EntryCodeView: View {
    @StateObject private var viewModel: EntryCodeViewModel
    @Environment(\.dismiss) private var dismiss
    
    let concertId: Int64
    let sessionId: Int64
    let isPreview: Bool
    
    init(concertId: Int64, sessionId: Int64, isPreview: Bool = false, viewModel: EntryCodeViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? EntryCodeViewModel())
        self.concertId = concertId
        self.sessionId = sessionId
        self.isPreview = isPreview
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                    .padding(.top, geometry.safeAreaInsets.top + 8)
                    
                    Spacer()
                    
                    // 텍스트 영역
                    VStack(spacing: 20) {
                        Text("입장 확인 전 안내")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.dketBlue)
                            .padding(.bottom, 8)
                        
                        (
                            Text("관객에게 아래 인증번호를 안내해주세요.\n관객이 앱에 인증번호를 입력하면 입장 준비가 완료됩니다.\n\n이후 ") +
                            Text("[티켓 검증하기]")
                                .foregroundColor(Color.dketBlue)
                                .fontWeight(.semibold) +
                            Text(" 버튼을 눌러 QR을 스캔하면\n입장 처리가 완료됩니다.")
                        )
                        .font(.system(size: 16, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, -80)
                    
                    Spacer()
                    
                    // 인증번호 표시
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.bottom, 80)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.bottom, 80)
                    } else {
                        HStack(spacing: 30) {
                            ForEach(Array(viewModel.entryCode), id: \.self) { digit in
                                Text(String(digit))
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(Color.dketBlue)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    
                    Spacer()
                    
                    // 버튼
                    Button {
                        // QR 인식 이동 로직
                    } label: {
                        Text("티켓 검증하기")
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
            .ignoresSafeArea(edges: .all)
            .task {
                if !isPreview {
                    await viewModel.loadEntryCode(concertId: concertId, sessionId: sessionId)
                }
            }
        }
    }
}

