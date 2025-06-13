import SwiftUI

struct PopoverView<Content: View>: View {
    let content: Content
    let background: BackgroundType
    let isVisible: Bool
    
    init(
        isVisible: Bool,
        background: BackgroundType,
        @ViewBuilder content: () -> Content
    ) {
        self.isVisible = isVisible
        self.background = background
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: 300)
            .padding(16)
            .background(
                Group {
                    switch background {
                    case .blur:
                        VisualEffectView(material: .popover, blendingMode: .behindWindow)
                    case .solid:
                        Color(NSColor.windowBackgroundColor)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.95)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
    }
}

enum BackgroundType: String, CaseIterable {
    case blur
    case solid
    
    var localizedName: String {
        switch self {
        case .blur:
            return "Blur"
        case .solid:
            return "Solid"
        }
    }
} 