import SwiftUI

struct NotificationView: View {
    let trackInfo: TrackInfo
    let duration: TimeInterval
    let isVisible: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            trackInfo.artwork
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Now Playing")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Text(trackInfo.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                
                Text(trackInfo.artist)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.95)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
    }
} 