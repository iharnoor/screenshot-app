import Foundation
import ScreenCaptureKit
import AppKit
import SwiftUI

@MainActor
class ScreenshotManager: ObservableObject {
    @Published var capturedImage: NSImage?
    @Published var isCapturing = false
    @Published var errorMessage: String?
    
    private var availableContent: SCShareableContent?
    
    init() {
        Task {
            await requestPermissions()
        }
    }
    
    private func requestPermissions() async {
        do {
            self.availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        } catch {
            self.errorMessage = "Failed to get screen content: \(error.localizedDescription)"
        }
    }
    
    func captureFullScreen() async {
        guard !isCapturing else { return }
        
        isCapturing = true
        errorMessage = nil
        
        do {
            guard let display = availableContent?.displays.first else {
                throw ScreenshotError.noDisplayFound
            }
            
            let filter = SCContentFilter(display: display, excludingWindows: [])
            let configuration = SCStreamConfiguration()
            configuration.width = Int(display.width)
            configuration.height = Int(display.height)
            configuration.pixelFormat = kCVPixelFormatType_32BGRA
            
            let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            
            let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
            self.capturedImage = nsImage
            
        } catch {
            self.errorMessage = "Screenshot failed: \(error.localizedDescription)"
        }
        
        isCapturing = false
    }
    
    func captureWindow() async {
        guard !isCapturing else { return }
        
        isCapturing = true
        errorMessage = nil
        
        do {
            guard let window = availableContent?.windows.first(where: { !$0.isOnScreen }) ??
                              availableContent?.windows.first else {
                throw ScreenshotError.noWindowFound
            }
            
            let filter = SCContentFilter(desktopIndependentWindow: window)
            let configuration = SCStreamConfiguration()
            configuration.width = Int(window.frame.width)
            configuration.height = Int(window.frame.height)
            configuration.pixelFormat = kCVPixelFormatType_32BGRA
            
            let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
            
            let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
            self.capturedImage = nsImage
            
        } catch {
            self.errorMessage = "Window capture failed: \(error.localizedDescription)"
        }
        
        isCapturing = false
    }
    
    func saveImage() {
        guard let image = capturedImage else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.nameFieldStringValue = "Screenshot-\(Date().timeIntervalSince1970)"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                self.saveImageToURL(image, url: url)
            }
        }
    }
    
    private func saveImageToURL(_ image: NSImage, url: URL) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            self.errorMessage = "Failed to process image"
            return
        }
        
        let imageData: Data?
        if url.pathExtension.lowercased() == "png" {
            imageData = bitmapRep.representation(using: .png, properties: [:])
        } else {
            imageData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
        }
        
        guard let data = imageData else {
            self.errorMessage = "Failed to convert image"
            return
        }
        
        do {
            try data.write(to: url)
        } catch {
            self.errorMessage = "Failed to save image: \(error.localizedDescription)"
        }
    }
}

enum ScreenshotError: LocalizedError {
    case noDisplayFound
    case noWindowFound
    
    var errorDescription: String? {
        switch self {
        case .noDisplayFound:
            return "No display found for screenshot"
        case .noWindowFound:
            return "No window found for screenshot"
        }
    }
}