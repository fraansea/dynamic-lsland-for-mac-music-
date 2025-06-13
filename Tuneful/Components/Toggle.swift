import SwiftUI

struct CustomToggle: View {
    let title: String
    @Binding var isOn: Bool
    let disabled: Bool
    
    init(_ title: String, isOn: Binding<Bool>, disabled: Bool = false) {
        self.title = title
        self._isOn = isOn
        self.disabled = disabled
    }
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .disabled(disabled)
        }
        .padding(.horizontal, 8)
        .frame(height: 34)
    }
} 