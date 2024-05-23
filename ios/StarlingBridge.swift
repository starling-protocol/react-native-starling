//
//  StarlingBridge.swift
//  react-native-starling
//
//  Created by Viktor Strate Kløvedal on 06/12/2023.
//

import Foundation
import Starling

@objc public class StarlingBridge: NSObject {
    weak var delegate: BluetoothDelegate!
    @objc public let eventQueue: DispatchQueue
    
    var starling: StarlingManager! = nil
    
    @objc public init(delegate: BluetoothDelegate) {
        self.delegate = delegate
        self.eventQueue = DispatchQueue(label: "starling-queue", qos: .userInitiated)
        super.init()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            NSLog("Notification request: \(granted ? "granted" : "denied")")
        }
        
        let options = StarlingOptions(enableSync: true)
        self.starling = StarlingManager(
            options: options,
            eventQueue: eventQueue,
            delegate: StarlingBridgeDelegate(bridge: self),
            logger: EventLogger(bridge: self)
        )
    }
    
    @objc public func loadPersistedState() {
        starling.loadPersistedState()
    }
    
    @objc public func deletePersistedState() {
        starling.deletePersistedState()
    }
    
    @objc public func startAdvertising(serviceUUID: String, characteristicUUID: String) {
        starling.startAdvertising(
            serviceUUID: UUID(uuidString: serviceUUID)!,
            characteristicUUID: UUID(uuidString: characteristicUUID)!
        )
    }
    
    @objc public func stopAdvertising() {
        starling.stopAdvertising()
    }
    
    @objc public func broadcastRouteRequest() {
        starling.broadcastRouteRequest()
    }
    
    @objc public func startLinkSession() throws -> URL {
        return try starling.startLinkSession()
    }
    
    @objc public func connectLinkSession(url: String) throws -> String {
        let contact = try starling.connectLinkSession(url: url)
        return contact.id
    }
    
    @objc public func deleteContact(_ contact: String) {
        starling.deleteContact(Contact(id: contact))
    }
    
    @objc public func sendMessage(contactID: String, body: String, attachedContact: String?) throws {
        let contact = Contact(id: contactID)
        let bodyData = body.data(using: .utf8)!
        
        try starling.syncAddMessage(contact: contact, message: bodyData, attachedContact: attachedContact.map { Contact(id: $0) })
    }
    
    @objc public func newGroup() throws -> String {
        let contact = try starling.newGroup()
        return contact.id
    }
    
    @objc public func joinGroup(groupSecret: String) throws -> String {
        guard let groupSecret = Data(base64Encoded: groupSecret) else {
            throw StarlingBridgeError.invalidBase64
        }
        
        let contact = try starling.joinGroup(groupSecret: groupSecret)
        return contact.id
    }
    
    @objc public func groupContactID(groupSecret: String) throws -> String {
        guard let groupSecret = Data(base64Encoded: groupSecret) else {
            throw StarlingBridgeError.invalidBase64
        }
        
        let contact = starling.groupContact(fromSecret: groupSecret)
        return contact.id
    }
    
    func sendEvent(_ event: Event) {
        DispatchQueue.main.async {
            if event.base != .debugLog {
                NSLog("[SWIFT BluetoothManager] sending event to UI: \(event.base.rawValue)")
            }
            
            self.delegate.sendEvent(name: event.base.rawValue, result: event.value)
        }
    }
    
    enum StarlingBridgeError: Error {
        case invalidBase64
    }
}

@objc public protocol BluetoothDelegate {
    func sendEvent(name: String, result: Any)
}

class StarlingBridgeDelegate: StarlingDelegate {
    let bridge: StarlingBridge
    
    init(bridge: StarlingBridge) {
        self.bridge = bridge
    }
    
    func advertisingStarted() {
        bridge.sendEvent(.advertisingStarted)
    }
    
    func advertisingEnded(reason: String?) {
        bridge.sendEvent(.advertisingEnded(reason ?? "unspecified reason"))
    }
    
    func deviceConnected(deviceAddress: DeviceAddress) {
        bridge.sendEvent(.deviceConnected(deviceAddress.id))
    }
    
    func deviceDisconnected(deviceAddress: DeviceAddress) {
        bridge.sendEvent(.deviceDisconnected(deviceAddress.id))
    }
    
    func messageReceived(session: Session, message: Data) {
        let str = String(data: message, encoding: .utf8) ?? "<Binary>"
        print("MESSAGE RECEIVED \(session) \(str)")
    }
    
    func messageDelivered(messageID: MessageID) {
        print("MESSAGE DELIVERED \(messageID)")
    }
    
    func sessionBroken(session: Session) {
        bridge.sendEvent(.sessionBroken(session.id.description))
    }
    
    func sessionEstablished(session: Session, contact: Contact, address: DeviceAddress) {
        bridge.sendEvent(.sessionEstablished(session.id.description, contact.id, address.id.uuidString))
    }
    
    // Disabled since sync is enabled
    func sessionRequested(session: Session, contact: Contact) -> Data? {
        return nil
    }
    
    func syncStateChanged(contact: Contact, change: StarlingStateChange) {
        let content = UNMutableNotificationContent()
        content.title = "New message from contact"
        content.body = contact.id
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              NSLog("Failed to send notification")
           }
        }
        
        switch change {
        case let .stateUpdated(newState: stateUpdate):
            bridge.sendEvent(.syncStateChange(contact.id, String(data: stateUpdate, encoding: .utf8)!))
        case .contactDeleted:
            bridge.sendEvent(.syncStateChange(contact.id, nil))
        }
    }
}

struct EventLogger: StarlingLogger {
    let bridge: StarlingBridge
    
    func log(priority: StarlingLogPrioroty, ctx: StarlingLogContext, message: String) {
        NSLog("[\(ctx)] \(message)")
        bridge.sendEvent(.debugLog("\(priority) \(ctx)", message))
    }
}
