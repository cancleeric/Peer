import MultipeerConnectivity
import Foundation

/// 多點連接管理器，負責底層連接功能
class MultipeerManager: NSObject {
    /// 單例模式
    static let shared = MultipeerManager()
    
    private let serviceType = "peer-example"
    private let session: MCSession
    private let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    private let nearbyServiceBrowser: MCNearbyServiceBrowser
    private let myPeerId: MCPeerID
    
    private override init() {
        let deviceId = UserDefaults.standard.string(forKey: "peer_device_id") ?? UUID().uuidString
        UserDefaults.standard.setValue(deviceId, forKey: "peer_device_id")
        let deviceName = "設備M_\(String(deviceId.prefix(4)))"
        
        myPeerId = MCPeerID(displayName: deviceName)
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
    }
    
    /// 啟動服務
    func startServices() {
        nearbyServiceAdvertiser.startAdvertisingPeer()
        nearbyServiceBrowser.startBrowsingForPeers()
        // 發送初始化事件
        EventManager.shared.send(.managerDidStart(myPeerId: myPeerId))
    }
    
    /// 停止服務
    func stopServices() {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
        nearbyServiceBrowser.stopBrowsingForPeers()
        EventManager.shared.send(.managerDidStop)
    }
    
    /// 發送數據到所有連接的節點
    func sendData(_ data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            EventManager.shared.send(.dataSent(data))
        } catch {
            EventManager.shared.send(.error(error))
        }
    }
}

// MARK: - MCSessionDelegate
extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        EventManager.shared.send(.peerStateChanged(peer: peerID, state: state))
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        EventManager.shared.send(.dataReceived(data: data, from: peerID))
    }
    
    // 其他必要的代理方法...
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - Service Delegates
extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        EventManager.shared.send(.invitationReceived(from: peerID, context: context, handler: invitationHandler))
    }
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        EventManager.shared.send(.peerDiscovered(peer: peerID, info: info))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        EventManager.shared.send(.peerLost(peer: peerID))
    }
} 