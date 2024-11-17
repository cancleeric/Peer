import Foundation
import Combine

/// 事件管理器
class EventManager {
    static let shared = EventManager()
    
    private let eventSubject = PassthroughSubject<PeerEvent, Never>()
    
    private init() {}
    
    /// 發送事件
    func send(_ event: PeerEvent) {
        DispatchQueue.main.async {
            self.eventSubject.send(event)
        }
    }
    
    /// 訂閱事件
    func subscribe(_ handler: @escaping (PeerEvent) -> Void) -> AnyCancellable {
        return eventSubject.sink(receiveValue: handler)
    }
} 