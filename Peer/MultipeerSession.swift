import MultipeerConnectivity
import os
import Foundation

/*
 MultipeerSession.swift
 
 這個類負責處理設備之間的多點連接功能：
 - 使用 MultipeerConnectivity 框架實現設備發現和連接
 - 自動為設備生成唯一標識符和顯示名稱
 - 管理可用設備列表和已連接設備列表
 - 處理設備之間的連接狀態變化
 */

class MultipeerSession: NSObject {
    /// 服務類型標識符，用於設備發現
    private let serviceType = "peer-example"
    
    /// 當前設備的唯一標識符
    let myPeerId: MCPeerID
    
    /// 管理點對點會話的核心組件
    private var session: MCSession
    
    /// 用於廣播本機設備存在的服務
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    
    /// 用於搜索附近設備的服務
    private var nearbyServiceBrowser: MCNearbyServiceBrowser
    
    /// 發現但尚未連接的設備列表
    @Published var availablePeers: [MCPeerID] = []
    
    /// 已經建立連接的設備列表
    @Published var connectedPeers: [MCPeerID] = []
    
    override init() {
        // 生成並保存設備的唯一標識符
        let deviceId = UserDefaults.standard.string(forKey: "peer_device_id") ?? UUID().uuidString
        UserDefaults.standard.setValue(deviceId, forKey: "peer_device_id")
        let deviceName = "設備S_\(String(deviceId.prefix(4)))"
        
        myPeerId = MCPeerID(displayName: deviceName)
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
        
        // 啟動設備發現服務
        nearbyServiceAdvertiser.startAdvertisingPeer()
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    /// 清理資源，停止設備發現服務
    deinit {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
        nearbyServiceBrowser.stopBrowsingForPeers()
    }
}

// MARK: - MCSessionDelegate
extension MultipeerSession: MCSessionDelegate {
    /// 處理設備連接狀態變化
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }
    
    /// 接收其他設備發送的數據
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    
    /// 接收數據流
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    /// 開始接收資源
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    /// 完成資源接收
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    /// 處理來自其他設備的連接邀請
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // 自動接受所有連接請求
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    /// 發現新的設備時調用
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    /// 設備離開範圍或不可用時調用
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll(where: { $0 == peerID })
        }
    }
} 