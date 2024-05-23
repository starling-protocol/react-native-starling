//
//  ReactNativeEvents.swift
//  react-native-starling
//
//  Created by Viktor Strate Kløvedal on 06/12/2023.
//

import Foundation

extension StarlingBridge {
  // List of emittable events
  enum Event {
      case advertisingStarted,
           advertisingEnded(String), // arg: reason of disconnect
           deviceConnected(UUID), // arg: device id
           deviceDisconnected(UUID), // arg: device id
           //messageReceived(String, String), // arg: contactID, Message
           debugLog(String, String), // arg: tag, body
           sessionEstablished(String, String, String), // arg: sessionID, contactID, deviceAddress
           sessionBroken(String), // arg: sessionID
           //messageDelivered(Int64), // arg: messageID
           syncStateChange(String, String?) // arg: contactID, JSON update
      
      var base: Base {
          switch self {
          case .advertisingStarted:
              return .advertisingStarted
          case .advertisingEnded(_):
              return .advertisingEnded
          case .deviceConnected(_):
              return .deviceConnected
          case .deviceDisconnected(_):
              return .deviceDisconnected
          //case .messageReceived(_, _):
          //    return .messageReceived
          case .sessionEstablished(_, _, _):
              return .sessionEstablished
          case .sessionBroken(_):
              return .sessionBroken
          //case .messageDelivered(_):
          //    return .messageDelivered
          case .syncStateChange(_, _):
              return .syncStateChange
          case .debugLog(_, _):
              return .debugLog
          }
      }
      
      var value: Any {
          switch self {
          case let .advertisingEnded(reason):
              return reason
          case let .deviceConnected(device):
              return device.uuidString
          case let .deviceDisconnected(device):
              return device.uuidString
          /*case let .messageReceived(contactID, body):
              return [
                "contactID": contactID,
                "body": body
              ]*/
          case let .debugLog(tag, body):
              return [
                "tag": tag,
                "body": body
              ]
          case let .sessionEstablished(session, contact, deviceAddress):
              return [
                "sessionID": session,
                "contactID": contact,
                "deviceAddress": deviceAddress,
              ]
          case let .sessionBroken(session):
              return session
          case .advertisingStarted:
              return 0
          //case let .messageDelivered(messageID):
          //    return messageID
          case let .syncStateChange(contact, json):
              return [
                "contactID": contact,
                "stateUpdate": json
              ]
          }
      }
      
      enum Base: String, CaseIterable {
          case advertisingStarted, advertisingEnded,
               deviceConnected, deviceDisconnected,
               messageReceived, debugLog,
               sessionEstablished, sessionBroken,
               messageDelivered, syncStateChange
      }
  }

  @objc public static var supportedEvents: [String] {
      return Event.Base.allCases.map(\.rawValue);
  }
}
