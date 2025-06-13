import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    let color: Color
    let disabled: Bool
    
    init(color: Color = .blue, disabled: Bool = false) {
        self.color = color
        self.disabled = disabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(disabled ? Color.gray.opacity(0.3) : color)
            )
            .foregroundColor(disabled ? .gray : .white)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
} 