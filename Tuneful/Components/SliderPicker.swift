import SwiftUI

struct SliderPicker<V: BinaryFloatingPoint>: View {
    let title: String
    let values: [V]
    @Binding var selection: V
    let valueFormatter: (V) -> LocalizedStringKey
    var disabled: Bool = false
    
    @State private var isHovering = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(disabled ? .tertiary : .primary)
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(values, id: \.self) { value in
                    Text(valueFormatter(value))
                        .tag(value)
                }
            }
            .frame(width: 150)
            .disabled(disabled)
            .onChange(of: selection) { _ in
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .levelChange,
                    performanceTime: .now
                )
            }
            .pickerStyle(.menu)
        }
        .padding(8)
        .opacity(disabled ? 0.7 : 1)
        .animation(.easeInOut(duration: 0.2), value: disabled)
    }
} 