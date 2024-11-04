//
//  ContentView.swift
//  AVCaptureEventInteractionSample
//
//  Created by saki on 2024/11/03.
//

import SwiftUI
import AVFoundation
import AVKit

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewControllerRepresentable {
    var session: AVCaptureSession
    var previewCALayer: CALayer
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        
        viewController.view.layer.addSublayer(previewCALayer)
        previewCALayer.frame = viewController.view.bounds
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = viewController.view.bounds
        viewController.view.layer.addSublayer(previewLayer)
        
        let interaction = AVCaptureEventInteraction { _ in }
        viewController.view.addInteraction(interaction)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        previewCALayer.frame = uiViewController.view.bounds
        if let previewLayer = uiViewController.view.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiViewController.view.bounds
        }
    }
}
