//
//  CameraView.swift
//  AVCaptureEventInteractionSample
//
//  Created by saki on 2024/11/04.
//

import AVFoundation
import Foundation
import SwiftUI

import AVFoundation
import Foundation
import SwiftUI

struct CameraView: View {
    @StateObject private var cameraModel = CameraModel()
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraModel.session, previewCALayer: CALayer(), cameraModel: cameraModel)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Button(action: {
                    cameraModel.capturePhoto()
                }) {
                    Text("💗")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.white.opacity(0.7))
                        .clipShape(Circle())
                }
                .padding(.bottom, 30)
                .onAppear(){
                    cameraModel.checkAuthorization()
                }
            }
        }
    }
}

