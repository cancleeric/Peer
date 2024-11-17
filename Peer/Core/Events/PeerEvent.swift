import MultipeerConnectivity

/// 定義所有可能的事件類型
enum PeerEvent {
    // 系統事件
    case managerDidStart(myPeerId: MCPeerID)
    case managerDidStop
    case error(Error)
    
    // 節點事件
    case peerDiscovered(peer: MCPeerID, info: [String: String]?)
    case peerLost(peer: MCPeerID)
    case peerStateChanged(peer: MCPeerID, state: MCSessionState)
    
    // 連接事件
    case invitationReceived(from: MCPeerID, context: Data?, handler: (Bool, MCSession?) -> Void)
    
    // 數據事件
    case dataSent(Data)
    case dataReceived(data: Data, from: MCPeerID)
} 