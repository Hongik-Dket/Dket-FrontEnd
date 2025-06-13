//
//  BuyerSessionPickerView.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/13/25.
//

import SwiftUI

struct BuyerSessionPickerView: View {
    @EnvironmentObject private var vm: BuyerEventViewModel
    let detail: EventDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("공연 날짜").font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.sessionList, id: \.id) { session in
                        let isSelected = vm.selectedSessionId == session.id
                        let isSelectable = vm.isSessionSelectable(session)
                        
                        Button(action: {
                            vm.selectSession(session.id)
                        }) {
                            VStack(spacing: 4) {
                                // 날짜 표시
                                Text(session.date.formatted(.dateTime.month().day()))
                                    .font(.subheadline)
                                    .bold()
                                
                                // 응모 상태 or 티켓 상태 표시
                                Text(vm.sessionApplyStatusLabel(session))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .frame(width: 72)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: isSelected ? 2 : 1)
                                    .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                            )
                        }
                        .disabled(!isSelectable)
                        .opacity(isSelectable ? 1.0 : 0.4)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
