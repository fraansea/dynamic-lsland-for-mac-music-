//
//  MainWindow.swift
//  Tuneful
//
//  Created by Martin Fekete on 18/08/2023.
//

import SwiftUI
import AppKit
import Defaults
import Combine

class MiniPlayerWindow: NSWindow {
    private var cancellables = Set<AnyCancellable>()
    private let playerManager: PlayerManager
    
    init(playerManager: PlayerManager) {
        self.playerManager = playerManager
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 100),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        setupPlayerMonitoring()
    }
    
    private func setupWindow() {
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        contentView = NSHostingView(
            rootView: MiniPlayerView(playerManager: playerManager)
                .frame(width: 300, height: 100)
        )
    }
    
    private func setupPlayerMonitoring() {
        playerManager.$currentTrack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] track in
                self?.updateWindow(with: track)
            }
            .store(in: &cancellables)
    }
    
    private func updateWindow(with track: Track?) {
        guard let track = track else {
            orderOut(nil)
            return
        }
        
        if !isVisible {
            makeKeyAndOrderFront(nil)
        }
    }
    
    func show() {
        makeKeyAndOrderFront(nil)
    }
    
    func hide() {
        orderOut(nil)
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Hide window", action: #selector(hideWindow(_:)), keyEquivalent: "")

        let windowStyleMenuItem = NSMenuItem(title: "Window style", action: nil, keyEquivalent: "")
        let windowMenu = NSMenu()
        windowMenu
            .addItem(withTitle: "Minimal", action: #selector(setCompactMiniPlayer(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerType] == .minimal ? .on : .off
        windowMenu
            .addItem(withTitle: "Horizontal", action: #selector(setHorizontalMiniPlayer(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerType] == .horizontal ? .on : .off
        windowMenu
            .addItem(withTitle: "Vertical", action: #selector(setVerticalMiniPlayer(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerType] == .vertical ? .on : .off
        windowStyleMenuItem.submenu = windowMenu
        menu.addItem(windowStyleMenuItem)
        
        let backgroundStyleMenuItem = NSMenuItem(title: "Background", action: nil, keyEquivalent: "")
        let backgroundMenu = NSMenu()
        backgroundMenu
            .addItem(withTitle: "Tint", action: #selector(setTintBg(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerBackground] == .glow ? .on : .off
        backgroundMenu
            .addItem(withTitle: "Transparent", action: #selector(setTransparentBg(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerBackground] == .transparent ? .on : .off
        backgroundMenu
            .addItem(withTitle: "Album art", action: #selector(setAlbumArtBg(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerBackground] == .albumArt ? .on : .off
        backgroundStyleMenuItem.submenu = backgroundMenu
        menu.addItem(backgroundStyleMenuItem)
        
        let sizeMenuItem = NSMenuItem(title: "Size", action: nil, keyEquivalent: "")
        let sizeMenu = NSMenu()
        sizeMenu
            .addItem(withTitle: "Small", action: #selector(setSmallWindow(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerScaleFactor] == .small ? .on : .off
        sizeMenu
            .addItem(withTitle: "Regular", action: #selector(setRegularWindow(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerScaleFactor] == .regular ? .on : .off
        sizeMenu
            .addItem(withTitle: "Large", action: #selector(setLargeWindow(_:)), keyEquivalent: "")
            .state = Defaults[.miniPlayerScaleFactor] == .large ? .on : .off
        sizeMenuItem.submenu = sizeMenu
        menu.addItem(sizeMenuItem)
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Settings...", action: #selector(settings(_:)), keyEquivalent: "")
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "Quit", action: #selector(quit(_:)), keyEquivalent: "")

        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView!)
    }

    @objc func setHorizontalMiniPlayer(_ sender: Any) {
        Defaults[.miniPlayerType] = .horizontal
    }

    @objc func setCompactMiniPlayer(_ sender: Any) {
        Defaults[.miniPlayerType] = .minimal
    }
    
    @objc func setVerticalMiniPlayer(_ sender: Any) {
        Defaults[.miniPlayerType] = .vertical
    }
    
    @objc func setTintBg(_ sender: Any) {
        Defaults[.miniPlayerBackground] = .glow
    }

    @objc func setAlbumArtBg(_ sender: Any) {
        Defaults[.miniPlayerBackground] = .albumArt
    }
    
    @objc func setTransparentBg(_ sender: Any) {
        Defaults[.miniPlayerBackground] = .transparent
    }
    
    @objc func setSmallWindow(_ sender: Any) {
        Defaults[.miniPlayerScaleFactor] = .small
    }

    @objc func setRegularWindow(_ sender: Any) {
        Defaults[.miniPlayerScaleFactor] = .regular
    }
    
    @objc func setLargeWindow(_ sender: Any) {
        Defaults[.miniPlayerScaleFactor] = .large
    }
    
    @objc func hideWindow(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.toggleMiniPlayerAndPlayerMenuItem), to: nil, from: nil)
    }
    
    @objc func settings(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.openSettings), to: nil, from: nil)
    }
    
    @objc func quit(_ sender: Any?) {
        NSApplication.shared.sendAction(#selector(AppDelegate.quit), to: nil, from: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NSPoint {
    static func fromString(_ string: String) -> NSPoint? {
        let components = string.split(separator: ",")
        guard components.count == 2,
              let x = Double(components[0]),
              let y = Double(components[1]) else {
            return nil
        }
        return NSPoint(x: x, y: y)
    }
}
