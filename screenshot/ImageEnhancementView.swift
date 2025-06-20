import SwiftUI
import AppKit

struct ImageEnhancementView: View {
    let image: NSImage
    let screenshotManager: ScreenshotManager
    
    @State private var shadowEnabled = false
    @State private var shadowRadius: Double = 20
    @State private var shadowOpacity: Double = 0.3
    @State private var shadowOffset: CGSize = CGSize(width: 0, height: 10)
    
    @State private var cornerRadius: Double = 12
    @State private var cornerRadiusEnabled = false
    
    @State private var backgroundEnabled = false
    @State private var backgroundType: BackgroundType = .solid
    @State private var backgroundColor = Color.white
    @State private var gradientColors = [Color.purple, Color.pink]
    
    @State private var padding: Double = 20
    
    @State private var textEnabled = false
    @State private var textContent = "Your Text Here"
    @State private var textSize: Double = 24
    @State private var textColor = Color.white
    @State private var textPosition: CGPoint = CGPoint(x: 0.5, y: 0.1)
    @State private var textBold = false
    @State private var textItalic = false
    
    @Environment(\.dismiss) private var dismiss
    
    enum BackgroundType: String, CaseIterable {
        case solid = "Solid"
        case gradient = "Gradient"
        case transparent = "Transparent"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            HStack(spacing: 20) {
                previewSection
                controlsSection
            }
            .padding()
            
            footerView
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color(.windowBackgroundColor))
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Enhance Screenshot")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add visual enhancements to make your screenshot stand out")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.headline)
            
            ZStack {
                backgroundView
                
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400, maxHeight: 300)
                    .cornerRadius(cornerRadiusEnabled ? cornerRadius : 0)
                    .shadow(
                        color: shadowEnabled ? .black.opacity(shadowOpacity) : .clear,
                        radius: shadowEnabled ? shadowRadius : 0,
                        x: shadowEnabled ? shadowOffset.width : 0,
                        y: shadowEnabled ? shadowOffset.height : 0
                    )
                    .padding(backgroundEnabled ? padding : 0)
            }
            .frame(maxWidth: 450, maxHeight: 350)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if backgroundEnabled {
            Group {
                switch backgroundType {
                case .solid:
                    backgroundColor
                case .gradient:
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .transparent:
                    Color.clear
                }
            }
        } else {
            Color.clear
        }
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Enhancement Options")
                .font(.headline)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    shadowControls
                    cornerRadiusControls
                    backgroundControls
                    paddingControls
                    textControls
                }
            }
        }
        .frame(maxWidth: 300)
    }
    
    private var shadowControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Drop Shadow", isOn: $shadowEnabled)
                .toggleStyle(.switch)
            
            if shadowEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Radius")
                        Spacer()
                        Text("\(Int(shadowRadius))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $shadowRadius, in: 0...50)
                    
                    HStack {
                        Text("Opacity")
                        Spacer()
                        Text("\(Int(shadowOpacity * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $shadowOpacity, in: 0...1)
                    
                    HStack {
                        Text("Offset X")
                        Spacer()
                        Text("\(Int(shadowOffset.width))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { shadowOffset.width },
                        set: { shadowOffset.width = $0 }
                    ), in: -50...50)
                    
                    HStack {
                        Text("Offset Y")
                        Spacer()
                        Text("\(Int(shadowOffset.height))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { shadowOffset.height },
                        set: { shadowOffset.height = $0 }
                    ), in: -50...50)
                }
                .padding(.leading, 16)
            }
        }
    }
    
    private var cornerRadiusControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Rounded Corners", isOn: $cornerRadiusEnabled)
                .toggleStyle(.switch)
            
            if cornerRadiusEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Radius")
                        Spacer()
                        Text("\(Int(cornerRadius))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $cornerRadius, in: 0...50)
                }
                .padding(.leading, 16)
            }
        }
    }
    
    private var backgroundControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Background", isOn: $backgroundEnabled)
                .toggleStyle(.switch)
            
            if backgroundEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Type", selection: $backgroundType) {
                        ForEach(BackgroundType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if backgroundType == .solid {
                        ColorPicker("Color", selection: $backgroundColor)
                    } else if backgroundType == .gradient {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gradient Colors")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                ColorPicker("Start", selection: $gradientColors[0])
                                ColorPicker("End", selection: $gradientColors[1])
                            }
                        }
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
    
    private var paddingControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Padding")
                Spacer()
                Text("\(Int(padding))")
                    .foregroundColor(.secondary)
            }
            Slider(value: $padding, in: 0...100)
        }
    }
    
    private var textControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Text Overlay", isOn: $textEnabled)
                .toggleStyle(.switch)
            
            if textEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Text Content", text: $textContent)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        Text("Size")
                        Spacer()
                        Text("\(Int(textSize))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $textSize, in: 12...72)
                    
                    ColorPicker("Text Color", selection: $textColor)
                    
                    HStack {
                        Toggle("Bold", isOn: $textBold)
                            .toggleStyle(.switch)
                        Toggle("Italic", isOn: $textItalic)
                            .toggleStyle(.switch)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Position")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("X")
                            Slider(value: Binding(
                                get: { textPosition.x },
                                set: { textPosition.x = $0 }
                            ), in: 0...1)
                        }
                        
                        HStack {
                            Text("Y")
                            Slider(value: Binding(
                                get: { textPosition.y },
                                set: { textPosition.y = $0 }
                            ), in: 0...1)
                        }
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
    
    private var footerView: some View {
        HStack {
            Button("Reset") {
                resetToDefaults()
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            
            Button("Apply & Save") {
                applyEnhancements()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func resetToDefaults() {
        shadowEnabled = false
        shadowRadius = 20
        shadowOpacity = 0.3
        shadowOffset = CGSize(width: 0, height: 10)
        cornerRadiusEnabled = false
        cornerRadius = 12
        backgroundEnabled = false
        backgroundType = .solid
        backgroundColor = .white
        gradientColors = [.purple, .pink]
        padding = 20
        textEnabled = false
        textContent = "Your Text Here"
        textSize = 24
        textColor = .white
        textPosition = CGPoint(x: 0.5, y: 0.1)
        textBold = false
        textItalic = false
    }
    
    private func applyEnhancements() {
        let enhancedImage = createEnhancedImage()
        screenshotManager.capturedImage = enhancedImage
        dismiss()
    }
    
    private func createEnhancedImage() -> NSImage {
        let originalSize = image.size
        let paddingValue = backgroundEnabled ? padding : 0
        let newSize = NSSize(
            width: originalSize.width + (paddingValue * 2),
            height: originalSize.height + (paddingValue * 2)
        )
        
        let enhancedImage = NSImage(size: newSize)
        enhancedImage.lockFocus()
        
        let context = NSGraphicsContext.current?.cgContext
        
        if backgroundEnabled && backgroundType != .transparent {
            let backgroundRect = NSRect(origin: .zero, size: newSize)
            
            switch backgroundType {
            case .solid:
                NSColor(backgroundColor).setFill()
                backgroundRect.fill()
            case .gradient:
                let gradient = NSGradient(colors: gradientColors.map { NSColor($0) })
                gradient?.draw(in: backgroundRect, angle: 315)
            case .transparent:
                break
            }
        }
        
        let imageRect = NSRect(
            x: paddingValue,
            y: paddingValue,
            width: originalSize.width,
            height: originalSize.height
        )
        
        if shadowEnabled {
            context?.setShadow(
                offset: CGSize(width: shadowOffset.width, height: -shadowOffset.height),
                blur: shadowRadius,
                color: NSColor.black.withAlphaComponent(shadowOpacity).cgColor
            )
        }
        
        if cornerRadiusEnabled {
            let path = NSBezierPath(roundedRect: imageRect, xRadius: cornerRadius, yRadius: cornerRadius)
            path.addClip()
        }
        
        image.draw(in: imageRect)
        
        if textEnabled && !textContent.isEmpty {
            let textRect = NSRect(
                x: imageRect.origin.x + (imageRect.width * textPosition.x) - 100,
                y: imageRect.origin.y + (imageRect.height * (1 - textPosition.y)) - 50,
                width: 200,
                height: 100
            )
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            var fontDescriptor = NSFontDescriptor(name: "Helvetica", size: textSize)
            if textBold {
                fontDescriptor = fontDescriptor.withSymbolicTraits(.bold)
            }
            if textItalic {
                fontDescriptor = fontDescriptor.withSymbolicTraits(.italic)
            }
            
            let font = NSFont(descriptor: fontDescriptor, size: textSize) ?? NSFont.systemFont(ofSize: textSize)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor(textColor),
                .paragraphStyle: paragraphStyle
            ]
            
            textContent.draw(in: textRect, withAttributes: attributes)
        }
        
        enhancedImage.unlockFocus()
        
        return enhancedImage
    }
}

#Preview {
    ImageEnhancementView(
        image: NSImage(systemSymbolName: "photo", accessibilityDescription: nil) ?? NSImage(),
        screenshotManager: ScreenshotManager()
    )
}