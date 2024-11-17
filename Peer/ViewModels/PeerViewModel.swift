import Foundation
import MultipeerConnectivity
import Combine

class PeerViewModel: ObservableObject {
    @Published private(set) var availablePeers: [MCPeerID] = []
    @Published private(set) var connectedPeers: [MCPeerID] = []
    @Published private(set) var myPeerId: MCPeerID?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 訂閱事件
        EventManager.shared.subscribe { [weak self] event in
            self?.handleEvent(event)
        }.store(in: &cancellables)
        
        // 啟動服務
        MultipeerManager.shared.startServices()
    }
    
    private func handleEvent(_ event: PeerEvent) {
        switch event {
        case .managerDidStart(let peerId):
            myPeerId = peerId
            
        case .peerDiscovered(let peer, _):
            if !availablePeers.contains(peer) {
                availablePeers.append(peer)
            }
            
        case .peerLost(let peer):
            availablePeers.removeAll(where: { $0 == peer })
            
        case .peerStateChanged(let peer, let state):
            switch state {
            case .connected:
                if !connectedPeers.contains(peer) {
                    connectedPeers.append(peer)
                }
            case .notConnected:
                connectedPeers.removeAll(where: { $0 == peer })
            default:
                break
            }
            
        default:
            break
        }
    }
} 