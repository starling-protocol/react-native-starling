package com.starling

import com.example.starling.Contact
import com.example.starling.DeviceAddress
import com.example.starling.MessageID
import com.example.starling.Session
import com.example.starling.StarlingCallback

class CallbackEvents(val module: StarlingModule) : StarlingCallback {
  override fun advertisingEnded(reason: String) {
    module.sendEvent(StarlingEvent.advertisingStopped(reason))
  }

  override fun advertisingStarted() {
    module.sendEvent(StarlingEvent.advertisingStarted())
  }

  override fun deviceConnected(deviceAddress: DeviceAddress) {
    module.sendEvent(StarlingEvent.deviceConnected(deviceAddress.address))
  }

  override fun deviceDisconnected(deviceAddress: DeviceAddress) {
    module.sendEvent(StarlingEvent.deviceDisconnected(deviceAddress.address))
  }

  override fun messageDelivered(messageID: MessageID) {
    //module.sendEvent(StarlingEvent.messageDelivered(messageID.id))
  }

  override fun messageReceived(session: Session, message: ByteArray) {
    /*val msgStr = String(message, Charsets.UTF_8)
    module.sendEvent(StarlingEvent.messageReceived(contact.id, msgStr))*/
  }

  override fun sessionBroken(session: Session) {
    module.sendEvent(StarlingEvent.sessionBroken(session.id.toString()))
  }

  override fun sessionEstablished(
    session: Session,
    contact: Contact,
    deviceAddress: DeviceAddress
  ) {
    module.sendEvent(
      StarlingEvent.sessionEstablished(
        session.id.toString(),
        contact.id,
        deviceAddress.address
      )
    )
  }

  override fun sessionRequested(session: Session, contact: Contact): ByteArray? {
    return null
  }

  override fun syncStateChanged(contact: Contact, stateUpdate: ByteArray) {
    val stateStr = String(stateUpdate, Charsets.UTF_8)
    module.sendEvent(StarlingEvent.syncStateChange(contact.id, stateStr))
  }

}
