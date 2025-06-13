//
//  MenuBarManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 05/01/2024.
//

import SwiftUI
import Combine
import AppKit

class StatusBarItemManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var statusBarItem: NSStatusItem?
    @Published private(set) var isVisible = false
    @Published private(set) var currentTitle: String = ""
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let playerManager: PlayerManager
    private let updateQueue = DispatchQueue(label: "com.tuneful.statusbar", qos: .userInteractive)
    private var titleUpdateWorkItem: DispatchWorkItem?
    private let maxTitleLength = 50
    
    // MARK: - Initialization
    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
        setupStatusBarItem()
        setupPlayerMonitoring()
    }
    
    deinit {
        titleUpdateWorkItem?.cancel()
        statusBarItem = nil
    }
    
    // MARK: - Setup Methods
    private func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "music.note", accessibilityDescription: "Tuneful")
            button.imagePosition = .imageLeft
            button.imageScaling = .scaleProportionallyDown
            button.target = self
            button.action = #selector(statusBarButtonClicked)
        }
    }
    
    private func setupPlayerMonitoring() {
        playerManager.$currentTrack
            .receive(on: updateQueue)
            .sink { [weak self] track in
                self?.updateStatusBarItem(with: track)
            }
            .store(in: &cancellables)
        
        playerManager.$isPlaying
            .receive(on: updateQueue)
            .sink { [weak self] isPlaying in
                self?.updatePlaybackState(isPlaying)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Update Methods
    private func updateStatusBarItem(with track: Track?) {
        titleUpdateWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            if let track = track {
                let title = self.formatTitle(track)
                DispatchQueue.main.async {
                    self.currentTitle = title
                    self.statusBarItem?.button?.title = title
                }
            } else {
                DispatchQueue.main.async {
                    self.currentTitle = ""
                    self.statusBarItem?.button?.title = ""
                }
            }
        }
        
        titleUpdateWorkItem = workItem
        updateQueue.async(execute: workItem)
    }
    
    private func updatePlaybackState(_ isPlaying: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let button = self.statusBarItem?.button {
                let imageName = isPlaying ? "music.note" : "music.note.list"
                button.image = NSImage(systemSymbolName: imageName, accessibilityDescription: "Tuneful")
            }
        }
    }
    
    private func formatTitle(_ track: Track) -> String {
        let title = "\(track.title) - \(track.artist)"
        if title.count > maxTitleLength {
            return String(title.prefix(maxTitleLength)) + "..."
        }
        return title
    }
    
    // MARK: - Public Methods
    func show() {
        DispatchQueue.main.async { [weak self] in
            self?.isVisible = true
            self?.statusBarItem?.isVisible = true
        }
    }
    
    func hide() {
        DispatchQueue.main.async { [weak self] in
            self?.isVisible = false
            self?.statusBarItem?.isVisible = false
        }
    }
    
    // MARK: - Actions
    @objc private func statusBarButtonClicked() {
        NotificationCenter.default.post(name: .statusBarButtonClicked, object: nil)
    }
    
    public func getMenuBarView(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> NSView {
        let title = self.getStatusBarTrackInfo(track: track, playerAppIsRunning: playerAppIsRunning, isPlaying: isPlaying)
        let image = self.getImage(track: track, playerAppIsRunning: playerAppIsRunning, isPlaying: isPlaying)
        let titleWidth = title.stringWidth(with: Constants.StatusBar.marqueeFont)
        
        var menuBarItemHeigth = 20.0
        var menuBarItemWidth = titleWidth == 0
            ? Constants.StatusBar.imageWidth
            : (Defaults[.menuBarItemWidth] > titleWidth  ? titleWidth + 5 : Defaults[.menuBarItemWidth] + 5)
        if Defaults[.statusBarIcon] != .hidden && titleWidth != 0 {
            menuBarItemWidth += Constants.StatusBar.imageWidth
        }
        
        let mainView = HStack(spacing: 7) {
            if Defaults[.statusBarIcon] != .hidden {
                image.frame(width: 18, height: 18)
            }
            
            if titleWidth != 0 || !playerAppIsRunning {
                Text(title)
                    .lineLimit(1)
                    .font(.system(size: 13, weight: .regular))
                    .offset(x: -2.5) // Prevent small jumps when toggling between scrolling on and off
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
        if Defaults[.statusBarIcon] == .hidden && titleWidth == 0 {
            menuBarItemHeigth = 0
            menuBarItemWidth = 0
       }
        
        let menuBarView = NSHostingView(rootView: mainView)
        menuBarView.frame = NSRect(x: 1, y: 1, width: menuBarItemWidth, height: menuBarItemHeigth)
        return menuBarView
    }
    
    // MARK: Private
    
    private func getStatusBarTrackInfo(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> String {
        let activePlayback = isPlaying && playerAppIsRunning
        
        if Defaults[.showStatusBarTrackInfo] == .never {
            return ""
        }
        
        if Defaults[.showStatusBarTrackInfo] == .whenPlaying && !activePlayback {
            return ""
        }
        
        if track.isEmpty() {
            return ""
        }
        
        if !playerAppIsRunning && !activePlayback {
            return "Open \(Defaults[.connectedApp].rawValue)"
        }
        
        return getTrackInfoDetails(track: track)
    }
    
    private func getTrackInfoDetails(track: Track) -> String {
        var title = track.title
        var album = track.album
        var artist = track.artist
        
        // In pocasts, replace artist name with podcast name (as artist name is empty)
        if artist.isEmpty { artist = album }
        if album.isEmpty { album = artist }
        if title.isEmpty { title = album }
        
        var trackInfo = ""
        switch Defaults[.trackInfoDetails] {
        case .artistAndSong:
            trackInfo = "\(artist) • \(title)"
        case .artist:
            trackInfo = "\(artist)"
        case .song:
            trackInfo = "\(title)"
        }
        
        return trackInfo
    }
    
    private func getImage(track: Track, playerAppIsRunning: Bool, isPlaying: Bool) -> AnyView {
        if isPlaying && Defaults[.showEqWhenPlayingMusic] && playerAppIsRunning {
            if Defaults[.statusBarIcon] == .albumArt {
                return AnyView(
                    Rectangle()
                        .fill(Color(nsColor: track.nsAlbumArt.averageColor ?? .white).gradient)
                        .mask { AudioSpectrumView().environmentObject(playerManager) }
                )
            } else {
                return AnyView(AudioSpectrumView().environmentObject(playerManager))
            }
        }
        
        if Defaults[.statusBarIcon] == .albumArt && playerAppIsRunning {
            return AnyView(track.albumArt.resizable().frame(width: 18, height: 18).cornerRadius(4))
        }
        
        return AnyView(Image(systemName: "music.quarternote.3"))
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let statusBarButtonClicked = Notification.Name("statusBarButtonClicked")
}
