//
//  OnboardingView.swift
//  Tuneful
//
//  Created by Martin Fekete on 03/08/2023.
//

import SwiftUI
import ScriptingBridge
import KeyboardShortcuts
import Defaults

struct OnboardingView: View {
    private enum Steps {
      case onAppPicker, onDetails, allDone
    }
    
    @Default(.viewedOnboarding) private var viewedOnboarding
    @State private var step: Steps = .onAppPicker
    @State private var finishedAlert = false
    
    var body: some View {
        VStack(alignment: .center) {
                VStack {
                    VStack {
                        HStack {
                            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            if step == .onAppPicker {
                                Text("Preferred music app")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                            } else if step == .onDetails {
                                Text("Permissions")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                            } else if step == .allDone {
                                Text("All done!")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                            } else {
                                EmptyView()
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    
                    HStack {
                        if step == .onAppPicker {
                            AppPicker()
                        } else if step == .onDetails {
                            Details(finishedAlert: $finishedAlert)
                        } else if step == .allDone {
                            AllDone()
                        } else {
                            EmptyView()
                        }
                    }
                    .frame(width: 300, height: 150)
                }
                .frame(width: 400, height: 250)
                .animation(Constants.mainAnimation, value: step)
                
                HStack {
                    if step == .onDetails {
                        Button("Back") {
                            step = .onAppPicker
                        }
                        .buttonStyle(CustomButtonStyle())
                    } else if step == .allDone {
                        Button("Back") {
                            step = .onDetails
                        }
                        .buttonStyle(CustomButtonStyle())
                    } else {
                        Button("Back") {
                            step = .onAppPicker
                        }
                        .buttonStyle(CustomButtonStyle())
                        .disabled(step == .onAppPicker)
                    }
                    
                    if step == .onAppPicker {
                        Button("Continue") {
                            step = .onDetails
                        }
                        .buttonStyle(CustomButtonStyle())
                    } else if step == .onDetails {
                        Button("Continue") {
                            step = .allDone
                        }
                        .buttonStyle(CustomButtonStyle())
                        .disabled(!finishedAlert)
                    } else {
                        Button("Finish") {
                            self.viewedOnboarding = true
                            NSApplication.shared.sendAction(#selector(AppDelegate.finishOnboarding), to: nil, from: nil)
                        }
                        .buttonStyle(CustomButtonStyle())
                    }
                }
                .frame(width: 300, height: 40)
            }
            .frame(width: 600, height: 500)
            .customWindowStyle()
    }
}

struct AppPicker: View {
    @Default(.connectedApp) private var connectedApp
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(ConnectedApps.allCases, id: \.rawValue) { app in
                    Section() {
                        Button(action: {
                            connectedApp = app
                        }) {
                            app.getIcon
                                .resizable()
                                .frame(width: 70, height: 70)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .disabled(!app.selectable)
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 80, height: 80)
                    }
                    .if(connectedApp == app) { button in
                        button.overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.secondary, lineWidth: 2)
                        )
                    }
                }
            }
            
            if !ConnectedApps.spotify.selectable {
                Text("Apple Music is the only avaiable music app as Spotify was not found. It should be located at the top level of Applications folder.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct Details: View {
    @Default(.connectedApp) private var connectedApp
    @Default(.viewedOnboarding) private var viewedOnboarding
    
    @Binding var finishedAlert: Bool
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showAlert = false
    @State private var success = false
    
    private var appName: Text {
        Text(connectedApp.localizedName)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("""
                 Tuneful requires permission to control \(appName) and display music data.
                 
                 Open \(appName) and click 'Enable permissions' below and select OK in the alert that is presented.
             """)
            .multilineTextAlignment(.center)
            
            Button("Enable permissions") {
                let consent = PermissionHelper.promptUserForConsent(for: connectedApp == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
                switch consent {
                case .granted:
                    alertTitle = Text("You are all set up!")
                    alertMessage = Text("Start playing a song!")
                    success = true
                    showAlert = true
                    viewedOnboarding = true
                case .closed:
                    alertTitle = Text("\(appName) is not opened")
                    alertMessage = Text("Please open \(appName) to enable permissions")
                    showAlert = true
                    success = false
                case .denied:
                    alertTitle = Text("Permission denied")
                    alertMessage = Text("Please go to System Settings > Privacy & Security > Automation, and check \(appName) under Tuneful")
                    showAlert = true
                    success = false
                case .notPrompted:
                    return
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: alertTitle, message: alertMessage, dismissButton: .default(Text("Got it!")) {
                    if success {
                        finishedAlert = true
                    }
                })
            }
        }
    }
}

struct AllDone: View {
    var body: some View {
        VStack {
            Text("""
                 To fully customize Tuneful, right-click Tuneful icon in menu bar and go to Settings.
             """)
            .multilineTextAlignment(.center)
        }
    }
}
