//
//  SettingView.swift
//  ProcessReporter
//
//  Created by Innei on 2023/6/24.
//

import LaunchAtLogin
import SwiftUI

struct SettingView: View {
    @EnvironmentObject var store: Store
    @State private var launchAtLogin = false

    private enum Tabs: Hashable {
        case general
    }

    var body: some View {
        TabView {
            Form {
                LaunchAtLogin.Toggle {
                    Text("Launch at login")
                }

                SecureField("API Key", text: $store.apiKey)
                TextField("Endpoint", text: $store.endpoint)
            }
            .padding(20)
            .frame(width: 350, height: 100)
            .tabItem {
                Label("General", systemImage: "gear")
            }
            .tag(Tabs.general)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
