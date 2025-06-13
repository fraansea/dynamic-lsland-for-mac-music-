import SwiftUI

struct Section<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(_ title: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            content()
        }
        .padding(.vertical, 8)
    }
} 