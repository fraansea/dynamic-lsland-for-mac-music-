//
//  PlayPauseButton.swift
//  Tuneful
//
//  Created by Martin Fekete on 08/08/2023.
//

import SwiftUI

struct PlayPauseButton: View {
    @EnvironmentObject var playerManager: PlayerManager
    @State private var transparency: Double = 0.0
    
    let buttonSize: CGFloat
    
    init(buttonSize: CGFloat = 30) {
        self.buttonSize = buttonSize
    }
    
    var body: some View {
        Button(action: {
            playerManager.togglePlayPause()
            transparency = 0.6
            withAnimation(.easeOut(duration: 0.2)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    transparency = 0.0
                }
            }
        }) {
            ZStack {
                Image(systemName: "pause.fill")
                    .resizable()
                    .frame(width: self.buttonSize, height: self.buttonSize)
                    .scaleEffect(playerManager.isPlaying ? 1.01 : 0.09)
                    .opacity(playerManager.isPlaying ? 1.01 : 0.09)
                    .animation(.interpolatingSpring(stiffness: 150, damping: 20), value: playerManager.isPlaying)
                
                Image(systemName: "play.fill")
                    .resizable()
                    .frame(width: self.buttonSize, height: self.buttonSize)
                    .scaleEffect(playerManager.isPlaying ? 0.09 : 1.01)
                    .opacity(playerManager.isPlaying ? 0.09 : 1.01)
                    .animation(.interpolatingSpring(stiffness: 150, damping: 20), value: playerManager.isPlaying)
            }
        }
        .buttonStyle(MusicControlButtonStyle())
    }
}
