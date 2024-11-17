import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @StateObject private var viewModel = PeerViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section("可用設備") {
                    ForEach(viewModel.availablePeers, id: \.self) { peer in
                        DeviceRow(peer: peer, isCurrentDevice: peer.displayName == viewModel.myPeerId?.displayName)
                    }
                    if viewModel.availablePeers.isEmpty {
                        Text("未發現設備")
                            .foregroundColor(.gray)
                    }
                }
                
                Section("已連接設備") {
                    ForEach(viewModel.connectedPeers, id: \.self) { peer in
                        DeviceRow(peer: peer, isCurrentDevice: peer.displayName == viewModel.myPeerId?.displayName)
                    }
                    if viewModel.connectedPeers.isEmpty {
                        Text("無連接設備")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Peer 設備")
        }
    }
} 