//
//  ContentView.swift
//  Peer
//
//  主視圖，顯示：
//  - 附近可用的設備列表
//  - 當前已連接的設備列表
//  - 標識當前設備的顯示
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    /// 多點連接會話管理器
    @StateObject private var multipeerSession = MultipeerSession()
    
    var body: some View {
        NavigationView {
            List {
                // 可用設備列表區段
                Section("可用設備") {
                    ForEach(multipeerSession.availablePeers, id: \.self) { peer in
                        HStack {
                            Text(peer.displayName)
                            // 標識當前設備
                            if peer.displayName == multipeerSession.myPeerId.displayName {
                                Text("(我的設備)")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    // 無可用設備時顯示提示
                    if multipeerSession.availablePeers.isEmpty {
                        Text("未發現設備")
                            .foregroundColor(.gray)
                    }
                }
                
                // 已連接設備列表區段
                Section("已連接設備") {
                    ForEach(multipeerSession.connectedPeers, id: \.self) { peer in
                        HStack {
                            Text(peer.displayName)
                            if peer.displayName == multipeerSession.myPeerId.displayName {
                                Text("(我的設備)")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    // 無連接設備時顯示提示
                    if multipeerSession.connectedPeers.isEmpty {
                        Text("無連接設備")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Peer 設備")
        }
    }
}

/// 預覽提供者
#Preview {
    ContentView()
}
