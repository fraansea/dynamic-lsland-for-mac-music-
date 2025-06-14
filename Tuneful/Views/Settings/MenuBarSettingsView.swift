//
//  MenuBarSettingsView.swift
//  Tuneful
//
//  Created by Martin Fekete on 06/01/2024.
//
import SwiftUI
import Settings
import Defaults

struct MenuBarSettingsView: View {
    @Default(.menuBarItemWidth) private var menuBarItemWidth
    @Default(.statusBarIcon) private var statusBarIcon
    @Default(.trackInfoDetails) private var trackInfoDetails
    @Default(.showStatusBarTrackInfo) private var showStatusBarTrackInfo
    @Default(.showMenuBarPlaybackControls) private var showMenuBarPlaybackControls
    @Default(.hideMenuBarItemWhenNotPlaying) private var hideMenuBarItemWhenNotPlaying
    @Default(.showEqWhenPlayingMusic) private var showEqWhenPlayingMusic
    
    var body: some View {
        Settings.Container(contentWidth: Constants.settingsWindowWidth) {
            Settings.Section(title: "") {
                Section("General") {
                    HStack {
                        Text("Menu bar icon")
                        
                        Spacer()
                        
                        Picker("", selection: $statusBarIcon) {
                            ForEach(StatusBarIcon.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .frame(width: 150)
                        .onChange(of: statusBarIcon) { _ in
                            if statusBarIcon == .hidden && showStatusBarTrackInfo == .never {
                                showStatusBarTrackInfo = .whenPlaying
                            }
                            sendTrackChangedNotification()
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(8)
                    
                    CustomToggle("Show equalizer when playing music", isOn: $showEqWhenPlayingMusic)
                        .onChange(of: showEqWhenPlayingMusic) { _ in
                            sendTrackChangedNotification()
                        }
                    
                    HStack {
                        Text("Hide menu bar item when nothing is playing")
                        
                        Spacer()
                        
                        Toggle(isOn: $hideMenuBarItemWhenNotPlaying) {
                            Text("")
                        }
                        .onChange(of: hideMenuBarItemWhenNotPlaying) { _ in
                            sendTrackChangedNotification()
                        }
                        .toggleStyle(.switch)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Show playback controls")
                        
                        Spacer()
                        
                        Toggle(isOn: $showMenuBarPlaybackControls) {
                            Text("")
                        }
                        .onChange(of: showMenuBarPlaybackControls) { _ in
                            NSApplication.shared.sendAction(#selector(AppDelegate.menuBarPlaybackControls), to: nil, from: nil)
                        }
                        .toggleStyle(.switch)
                    }
                    .padding(8)
                }
                
                Section("Song information in menu bar") {
                    HStack {
                        Text("Song info in menu bar")
                        
                        Spacer()
                        
                        Picker("", selection: $showStatusBarTrackInfo) {
                            ForEach(ShowStatusBarTrackInfo.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .onChange(of: showStatusBarTrackInfo) { _ in
                            if statusBarIcon == .hidden && showStatusBarTrackInfo == .never {
                                statusBarIcon = .appIcon
                            }
                            sendTrackChangedNotification()
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                    }
                    .padding(8)
                    
                    HStack {
                        Text("Song info details")
                            .foregroundStyle(showStatusBarTrackInfo == .never ? .tertiary : .primary)
                        
                        Spacer()
                        
                        Picker("", selection: $trackInfoDetails) {
                            ForEach(StatusBarTrackDetails.allCases, id: \.self) { value in
                                Text(value.localizedName).tag(value)
                            }
                        }
                        .onChange(of: trackInfoDetails) { _ in
                            sendTrackChangedNotification()
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        .disabled(showStatusBarTrackInfo == .never)
                    }
                    .padding(8)
                    
                    SliderPicker(
                        "Song info width",
                        values: Array(stride(from: 75, through: 300, by: 25)),
                        selection: $menuBarItemWidth
                    ) { value in
                        LocalizedStringKey("\(value, specifier: "%.0f") pixels")
                    }
                    .disabled(showStatusBarTrackInfo == .never)
                }
                .padding(.top, 10)
            }
        }
    }
    
    private func sendTrackChangedNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateMenuBarItem"), object: nil, userInfo: [:])
    }
}

#Preview {
    MenuBarSettingsView()
}
