//
//  ThirdStepView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/25/25.
//

import SwiftUI
import PhotosUI

struct ThirdStepView: View {
    @Binding var bannerImage: UIImage?
    @Binding var posterImage: UIImage?
    @Binding var photocardImages: [UIImage]
    
    @State private var bannerItem: PhotosPickerItem?
    @State private var posterItem: PhotosPickerItem?
    @State private var pickerItem: PhotosPickerItem?
    
    private let imageSize: CGFloat = 100
    private let maxPhotocards = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
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
            
            LabeledRow(label: "포토카드 이미지") {
                VStack(alignment: .leading, spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(photocardImages, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSize, height: imageSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            
                            if photocardImages.count < maxPhotocards {
                                PhotosPicker(selection: $pickerItem, matching: .images) {
                                    imagePlaceholder(uiImage: nil, showsPlus: true)
                                }
                                .frame(width: imageSize, height: imageSize)
                                .onChange(of: pickerItem) {
                                    loadImage(from: $0) { img in
                                        if let img {
                                            photocardImages.append(img)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if photocardImages.count >= maxPhotocards {
                        Text("📷 최대 \(maxPhotocards)장까지 업로드할 수 있어요")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            
            Spacer()
        }
        .padding(.horizontal, 30)
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
    
    private func loadImages(from items: [PhotosPickerItem], completion: @escaping ([UIImage]) -> Void) {
        Task {
            var images: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let ui = UIImage(data: data) {
                    images.append(ui)
                }
            }
            completion(images)
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

