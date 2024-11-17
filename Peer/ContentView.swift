//
//  ContentView.swift
//  Peer
//
//  Created by EricWang on 2024/11/17.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @StateObject private var multipeerSession = MultipeerSession()
    
    var body: some View {
        NavigationView {
            List {
                Section("可用设备") {
                    ForEach(multipeerSession.availablePeers, id: \.self) { peer in
                        HStack {
                            Text(peer.displayName)
                            if peer.displayName == multipeerSession.myPeerId.displayName {
                                Text("(我的设备)")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    if multipeerSession.availablePeers.isEmpty {
                        Text("未发现设备")
                            .foregroundColor(.gray)
                    }
                }
                
                Section("已连接设备") {
                    ForEach(multipeerSession.connectedPeers, id: \.self) { peer in
                        HStack {
                            Text(peer.displayName)
                            if peer.displayName == multipeerSession.myPeerId.displayName {
                                Text("(我的设备)")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    if multipeerSession.connectedPeers.isEmpty {
                        Text("无连接设备")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Peer 设备")
        }
    }
}

#Preview {
    ContentView()
}
