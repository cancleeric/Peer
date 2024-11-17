import MultipeerConnectivity
import os
import Foundation

class MultipeerSession: NSObject, ObservableObject {
    private let serviceType = "peer-example"
    let myPeerId: MCPeerID
    private var session: MCSession
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    private var nearbyServiceBrowser: MCNearbyServiceBrowser
    
    @Published var availablePeers: [MCPeerID] = []
    @Published var connectedPeers: [MCPeerID] = []
    
    override init() {
        // 生成唯一的设备名称
        let deviceId = UserDefaults.standard.string(forKey: "peer_device_id") ?? UUID().uuidString
        UserDefaults.standard.setValue(deviceId, forKey: "peer_device_id")
        let deviceName = "设备_\(String(deviceId.prefix(4)))"
        
        myPeerId = MCPeerID(displayName: deviceName)
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
        
        nearbyServiceAdvertiser.startAdvertisingPeer()
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
        nearbyServiceBrowser.stopBrowsingForPeers()
    }
}

extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll(where: { $0 == peerID })
        }
    }
} 