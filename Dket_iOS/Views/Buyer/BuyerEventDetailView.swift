//
//  BuyerEventDetailView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/6/25.
//

import SwiftUI

enum FloatingActionType: String {
    case apply = "티켓 응모하기"
    case purchase = "티켓 결제하기"
    case buy = "티켓 구매하기"
    case enter = "공연 입장하기"
    case view = "티켓 조회하기"
    case none = ""
}

struct BuyerEventDetailView: View {
    let eventId: Int64
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm: BuyerEventViewModel
    
    init(eventId: Int64) {
        self.eventId = eventId
        _vm = StateObject(wrappedValue: BuyerEventViewModel(eventId: eventId))
    }
    
    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().task {
                    await vm.onAppear()
                }
            case .failed(let error):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)
                    Text(error.localizedDescription)
                    Button("다시 시도") {
                        Task { await vm.fetch() }
                    }
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
        .overlay {
            if vm.showApplySuccessAlert {
                ApplySuccessModalView {
                    vm.showApplySuccessAlert = false
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
                        Task {
                            switch vm.floatingButtonTitle {
                            case "티켓 응모하기":
                                let success = await vm.applyToSelectedSession()
                                if success {
                                    vm.showApplySuccessAlert = true
                                    await vm.fetch() // 중복 응모 방지용 상태 업데이트
                                }
                            case "티켓 결제하기", "티켓 구매하기":
                                _ = await vm.purchaseTicket()
                                await vm.fetch()
                            default:
                                break
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
