//
//  BuyerSearchView.swift
//  Dket_iOS
//
//  Created by 이지우 on 8/21/25.
//

import SwiftUI

struct BuyerSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = BuyerSearchViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            // MARK: - 상단 검색창
            HStack(spacing: 8) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                TextField("검색어를 입력하세요", text: $vm.query)
                    .padding(.horizontal)
                    .frame(height: 36)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await vm.search() }
                    }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            // MARK: - 검색 결과
            ScrollView {
                if vm.isLoading {
                    ProgressView("검색 중...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 60)
                } else if vm.results.isEmpty && !vm.query.isEmpty {
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 60)
                } else {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(vm.results) { concert in
                            NavigationLink(destination: BuyerConcertDetailView(concertId: concert.concertId)) {
                                SearchResultRow(concert: concert)
                            }
                            .buttonStyle(.plain) 
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .onChange(of: vm.query) { _ in
            Task { await vm.search() }
        }
    }
}

// MARK: - 검색 결과 셀
struct SearchResultRow: View {
    let concert: ConcertSearchCardDTO
    
    private var formattedPeriod: String {
        let start = DateFormatter.yyyyMMdd.date(from: concert.startDate)
        let end = DateFormatter.yyyyMMdd.date(from: concert.endDate)
        let startStr = start.map { DateFormatter.yyyyDMMDdd.string(from: $0) } ?? concert.startDate
        let endStr = end.map { DateFormatter.yyyyDMMDdd.string(from: $0) } ?? concert.endDate
        return "\(startStr) ~ \(endStr)"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 포스터 이미지
            AsyncImage(url: URL(string: concert.imageUrl)) { img in
                img.resizable()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 105, height: 140)
            .cornerRadius(8)
            .grayscale(concert.concertStatus == .ended ? 1 : 0) // 공연 종료면 회색 처리
            
            VStack(alignment: .leading, spacing: 6) {
                Text(concert.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(concert.location)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black)
                
                Text(formattedPeriod)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(concert.concertStatus.label)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.dketBlue)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
