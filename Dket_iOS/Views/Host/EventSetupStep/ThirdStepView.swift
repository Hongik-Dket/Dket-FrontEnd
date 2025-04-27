//
//  ThirdStepView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI
import PhotosUI

struct ThirdStepView: View {
    // 상위에서 바인딩으로 내려받는 상태
    @Binding var bannerImage: UIImage?
    @Binding var posterImage: UIImage?
    @Binding var photocardImage: UIImage?

    // 내부에서 PhotosPickerItem 으로 받을 임시 변수
    @State private var bannerItem: PhotosPickerItem?
    @State private var posterItem: PhotosPickerItem?
    @State private var photocardItem: PhotosPickerItem?

    // 모든 플레이스홀더 크기
    private let imageSize: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 공연 배너
            LabeledRow(label: "공연 배너 이미지") {
                PhotosPicker(
                    selection: $bannerItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    imagePlaceholder(uiImage: bannerImage)
                }
                .onChange(of: bannerItem) { loadImage(from: $0) { bannerImage = $0 } }
            }

            // 공연 포스터
            LabeledRow(label: "공연 포스터 이미지") {
                PhotosPicker(
                    selection: $posterItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    imagePlaceholder(uiImage: posterImage)
                }
                .onChange(of: posterItem) { loadImage(from: $0) { posterImage = $0 } }
            }

            // 포토카드 (선택)
            LabeledRow(label: "포토카드 이미지") {
                PhotosPicker(
                    selection: $photocardItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    imagePlaceholder(uiImage: photocardImage, showsPlus: true)
                }
                .onChange(of: photocardItem) { loadImage(from: $0) { photocardImage = $0 } }
            }

            Spacer()
        }
        .padding(.horizontal, 30) // 좌측/우측 여백 step1과 동일
    }

    // MARK: - PhotosPickerItem → UIImage 로 비동기 로드
    private func loadImage(from item: PhotosPickerItem?, completion: @escaping (UIImage?) -> Void) {
        guard let item else { return completion(nil) }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let ui = UIImage(data: data)
            {
                completion(ui)
            } else {
                completion(nil)
            }
        }
    }

    // MARK: - 플레이스홀더 + 실제 이미지 뷰
    @ViewBuilder
    private func imagePlaceholder(uiImage: UIImage?, showsPlus: Bool = false) -> some View {
        if let img = uiImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .clipped()
                .cornerRadius(8)
        } else {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                if showsPlus {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(8)
        }
    }
}

