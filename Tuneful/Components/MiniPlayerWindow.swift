import SwiftUI

struct MiniPlayerWindow: View {
    let isVisible: Bool
    let isPlaying: Bool
    let trackInfo: TrackInfo
    let background: BackgroundType
    let scaleFactor: CGFloat
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                trackInfo.artwork
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60 * scaleFactor, height: 60 * scaleFactor)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(trackInfo.title)
                        .font(.system(size: 14 * scaleFactor, weight: .medium))
                        .lineLimit(1)
                    
                    Text(trackInfo.artist)
                        .font(.system(size: 12 * scaleFactor))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: onPrevious) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 14 * scaleFactor))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onPlayPause) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 16 * scaleFactor))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: onNext) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 14 * scaleFactor))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .frame(width: 300 * scaleFactor)
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

struct TrackInfo {
    let title: String
    let artist: String
    let artwork: Image
} 