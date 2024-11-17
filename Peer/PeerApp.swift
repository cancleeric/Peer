//
//  PeerApp.swift
//  Peer
//
//  應用程序的主入口點：
//  - 使用 SwiftUI 的 App 協議
//  - 設置應用程序的主視圖結構
//  - 初始化應用程序的根視圖
//

import SwiftUI

@main
struct PeerApp: App {
    // 持有 MultipeerSession 的實例
    private let multipeerSession = MultipeerSession()
    
    /// 配置應用程序的主場景
    var body: some Scene {
        WindowGroup {
            // 設置 ContentView 為應用程序的根視圖
            ContentView()
        }
    }
}
