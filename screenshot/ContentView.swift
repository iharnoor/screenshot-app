//
//  ContentView.swift
//  screenshot
//
//  Created by harnoorsingh on 6/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var screenshotManager = ScreenshotManager()
    @State private var showEnhanceOptions = false
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            if let image = screenshotManager.capturedImage {
                imagePreviewSection(image: image)
            } else {
                placeholderView
            }
            
            captureButtonsSection
            
            if let errorMessage = screenshotManager.errorMessage {
                errorView(message: errorMessage)
            }
        }
        .padding(30)
        .frame(minWidth: 600, minHeight: 500)
        .background(Color(.windowBackgroundColor))
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
            
            Text("Screenshot Pro")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Capture, enhance, and save your screenshots")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.controlBackgroundColor))
            .frame(height: 300)
            .overlay(
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font( . sy1stem(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No screenshot captured yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Click one of the buttons below to take a screenshot")
                        .font(.subheadline)
                        .foregroundColor(Color.secondary.opacity(0.7))
                }
            )
    }
    
    private func imagePreviewSection(image: NSImage) -> some View {
        VStack(spacing: 12) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 4)
            
            HStack(spacing: 12) {
                Button("Enhance") {
                    showEnhanceOptions.toggle()
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                
                Button("Save") {
                    screenshotManager.saveImage()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                
                Button("Clear") {
                    screenshotManager.capturedImage = nil
                    screenshotManager.errorMessage = nil
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
        .sheet(isPresented: $showEnhanceOptions) {
            ImageEnhancementView(image: image, screenshotManager: screenshotManager)
        }
    }
    
    private var captureButtonsSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                Task {
                    await screenshotManager.captureFullScreen()
                }
            }) {
                Label("Full Screen", systemImage: "rectangle.dashed")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(screenshotManager.isCapturing)
            
            Button(action: {
                Task {
                    await screenshotManager.captureWindow()
                }
            }) {
                Label("Window", systemImage: "macwindow")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(screenshotManager.isCapturing)
        }
        .overlay(
            Group {
                if screenshotManager.isCapturing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        )
    }
    
    private func errorView(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .foregroundColor(.secondary)
                .font(.caption)
            
            Spacer()
            
            Button("Dismiss") {
                screenshotManager.errorMessage = nil
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    ContentView()
}
