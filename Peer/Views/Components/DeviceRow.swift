import SwiftUI
import MultipeerConnectivity

struct DeviceRow: View {
    let peer: MCPeerID
    let isCurrentDevice: Bool
    
    var body: some View {
        HStack {
            Text(peer.displayName)
            if isCurrentDevice {
                Text("(我的設備)")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
        }
    }
} 