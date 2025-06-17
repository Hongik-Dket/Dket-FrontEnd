//
//  QRScanView.swift
//  Dket_iOS
//
//  Created by 이지우 on 4/8/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct QRScanView: UIViewControllerRepresentable {
    /// 스캔된 코드가 전달됩니다.
    var onScan: (String) -> Void
    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }
    
    func makeUIViewController(context: Context) -> AVCaptureViewController {
        let vc = AVCaptureViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AVCaptureViewController, context: Context) {}
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onScan: (String) -> Void
        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard let m = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let code = m.stringValue else { return }
            onScan(code)
        }
    }
}

/// 이 컨트롤러가 실제 카메라 프리뷰 + 메타데이터(바코드) 인식을 처리합니다.
class AVCaptureViewController: UIViewController {
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
    private let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // 1) 카메라 인풋
        guard let device = AVCaptureDevice.default(for: .video),
              let input  = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else { return }
        session.addInput(input)
        
        // 2) 메타데이터 아웃풋
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(delegate, queue: .main)
        output.metadataObjectTypes = [.qr]
        
        // 3) 프리뷰 레이어
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.layer.bounds
        view.layer.addSublayer(preview)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
    }
}


