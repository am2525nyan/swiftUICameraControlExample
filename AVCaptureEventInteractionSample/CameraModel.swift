//
//  CameraModel.swift
//  AVCaptureEventInteractionSample
//
//  Created by saki on 2024/11/04.
//

import AVFoundation
import Foundation
import SwiftUI

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate,AVCaptureSessionControlsDelegate {
    @Published var session = AVCaptureSession()
    private var output = AVCapturePhotoOutput()
    private var photoData: Data?
    
    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera)
        else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        let sessionQueue = DispatchQueue(label: "SessionQueue")
        let systemZoomSlider = AVCaptureSystemZoomSlider(device: camera) {
            value in
            debugPrint("Zoom Factor: \(value)")
        }
        
        let systemExposureSlider = AVCaptureSystemExposureBiasSlider(
            device: camera
        ) { value in
            debugPrint("Exposure: \(value)")
        }
        
        let focusSlider = AVCaptureSlider(
            "Focus", symbolName: "scope", in: 0...1)
        focusSlider.setActionQueue(sessionQueue) { [weak self] value in
            guard self != nil else { return }
            do {
                try camera.lockForConfiguration()
                camera.setFocusModeLocked(lensPosition: value) { _ in
                    print("Finished change lens position process.")
                }
                camera.unlockForConfiguration()
            } catch let error {
                print(error)
            }
        }
        
        let filterPicker = AVCaptureIndexPicker(
            "Filters", symbolName: "camera.filters",
            localizedIndexTitles: ["Filter 1", "Filter 2"])
        
        filterPicker.setActionQueue(sessionQueue) { index in
            print(index)
        }
        
        if session.supportsControls {
            for control in [
                filterPicker, focusSlider, systemZoomSlider,
                systemExposureSlider,
            ] {
                if session.canAddControl(control) {
                    session.addControl(control)
                }
            }
        }
        
        session.setControlsDelegate(self, queue: sessionQueue)
        session.commitConfiguration()
        DispatchQueue.global().async {
            self.session.startRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,  didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        self.photoData = data
        savePhotoToCameraRoll(data)
        
    }
    func savePhotoToCameraRoll(_ data: Data) {
        guard let image = UIImage(data: data) else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {
        print("SessionControls did become active")
    }
    
    func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {
        print("SessionControls will enter fullscreen appearance")
    }
    
    func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {
        print("SessionControls will exit fullscreen appearance")
    }
    
    func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {
        print("SessionControls did become inactive")
    }
}
