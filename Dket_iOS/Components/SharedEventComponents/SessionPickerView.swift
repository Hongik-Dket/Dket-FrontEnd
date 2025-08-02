//
//  Untitled.swift
//  Dket_iOS
//
//  Created by 이지우 on 6/5/25.
//

import SwiftUI

struct SessionPickerView: View {
    @EnvironmentObject private var vm: ConcertDetailViewModel
    let detail: ConcertDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("공연 날짜").font(.headline)
            Picker("Session", selection: $vm.selectedSessionId) {
                ForEach(detail.sessionIds, id: \.self) { id in
                    SessionLabel(id: id)
                        .tag(id as Int64?)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    @ViewBuilder
    private func SessionLabel(id: Int64) -> some View {
        if let session = vm.sessionCache[id] {
            Text(DateFormatter.sessionDateFormatter.string(from: session.date))
        } else {
            Text("세션 \(id)")
        }
    }
}
