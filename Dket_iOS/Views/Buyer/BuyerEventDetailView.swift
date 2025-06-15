//
//  BuyerEventDetailView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/6/25.
//

import SwiftUI

struct BuyerEventDetailView: View {
    let eventId: Int64
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm: BuyerEventViewModel
    
    @State private var showApplySuccessAlert = false
    
    init(eventId: Int64) {
        self.eventId = eventId
        _vm = StateObject(wrappedValue: BuyerEventViewModel(eventId: eventId))
    }
    
    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().task { await vm.fetch() }
            case .failed(let error):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)
                    Text(error.localizedDescription)
                    Button("다시 시도") { Task { await vm.fetch() } }
                }
            case .loaded:
                if let detail = vm.detail {
                    content(detail)
                }
            }
        }
        .navigationTitle("공연 상세")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    @ViewBuilder
    func content(_ detail: EventDetail) -> some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    PosterView(url: detail.poster)
                    BasicInfoView(detail: detail)
                    Divider()
                    
                    if detail.status == .applyNotOpened {
                        Text("응모 D-\(Date().daysUntil(detail.applyPeriod.lowerBound))일")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    } else {
                        BuyerSessionPickerView(detail: detail)
                            .environmentObject(vm)
                        Divider()
                        BuyerSessionStatSection()
                            .environmentObject(vm)
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            
            VStack {
                Spacer()
                if vm.floatingButtonTitle != "" {
                    Button(action: {
                        // TODO: 버튼 액션 처리 (예: 응모, 결제 등)
                        Task {
                            let success = await vm.applyToSelectedSession()
                            if success {
                                showApplySuccessAlert = true
                            }
                        }
                    }) {
                        Text(vm.floatingButtonTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 48)
                            .background(vm.isFloatingButtonEnabled ? Color.dketBlue : Color.gray)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                    }
                    .disabled(!vm.isFloatingButtonEnabled)
                    .padding(.bottom)
                }
            }
        }
        .overlay {
            if showApplySuccessAlert {
                ApplySuccessModalView {
                    showApplySuccessAlert = false
                }
            }
        }
    }
}

private struct BuyerSessionStatSection: View {
    @EnvironmentObject private var vm: BuyerEventViewModel
    
    var body: some View {
        if let event = vm.detail, let session = vm.selectedSession {
            VStack(alignment: .leading, spacing: 15) {
                Text(session.date.formatted(.dateTime.year().month().day()))
                    .font(.title3).bold()
                
                HStack {
                    Text("잔여 티켓")
                        .font(.caption)
                    Spacer()
                    Text("\(event.capacity - session.paidCount)장")
                }
                .font(.subheadline)
                
                let label = vm.sessionApplyStatusLabel(session)
                if !label.isEmpty {
                    HStack {
                        Text("상태")
                            .font(.caption)
                        Spacer()
                        Text(label)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
}
