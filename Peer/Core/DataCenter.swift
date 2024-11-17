import Foundation
import MultipeerConnectivity
import Combine

/// 數據中心，負責管理應用程序的所有數據狀態
class DataCenter: ObservableObject {
    /// 單例模式
    static let shared = DataCenter()
    
    /// 設備狀態數據
    @Published private(set) var deviceState: DeviceState = .init()
    
    private init() {}
    
    /// 更新可用設備列表
    func updateAvailablePeers(_ peers: [MCPeerID]) {
        DispatchQueue.main.async {
            self.deviceState.availablePeers = peers
        }
    }
    
    /// 更新已連接設備列表
    func updateConnectedPeers(_ peers: [MCPeerID]) {
        DispatchQueue.main.async {
            self.deviceState.connectedPeers = peers
        }
    }
}

/// 設備狀態模型
struct DeviceState {
    var availablePeers: [MCPeerID] = []
    var connectedPeers: [MCPeerID] = []
    var myPeerId: MCPeerID?
} 