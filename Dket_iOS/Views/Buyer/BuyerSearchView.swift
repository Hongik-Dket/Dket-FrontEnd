//
//  BuyerSearchView.swift
//  Dket_iOS
//
//  Created by 이지우 on 8/21/25.
//

import SwiftUI

struct BuyerSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""
    @State private var results: [SearchResultItem] = [] // 검색 결과

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.black)
                }

                TextField("검색어를 입력하세요", text: $query)
                    .padding(.horizontal)
                    .frame(height: 36)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .onSubmit {
                        Task { await searchConcerts() }
                    }

                Spacer()
            }
            .padding(.horizontal)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(results) { result in
                        SearchResultRow(item: result)
                    }
                }
                .padding()
            }

            Spacer()
        }
        .navigationBarBackButtonHidden()
        .onChange(of: query) { newValue in
            Task { await searchConcerts() }
        }
    }

    func searchConcerts() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        // 이 예시에서는 임시로 더미 데이터 생성
        results = (0..<5).map { i in
            .init(id: Int64(i), title: "공연 이름 길이 최대 여기까지 ~~~", location: "공연 장소", period: "2025.03.20 ~ 2025.03.21", statusText: "응모 중 (D-10)")
        }
    }
}

struct SearchResultItem: Identifiable {
    let id: Int64
    let title: String
    let location: String
    let period: String
    let statusText: String
}

struct SearchResultRow: View {
    let item: SearchResultItem

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 72, height: 96)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(item.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(item.period)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(item.statusText)
                    .font(.subheadline)
                    .foregroundColor(.dketBlue)
            }

            Spacer()
        }
    }
}
