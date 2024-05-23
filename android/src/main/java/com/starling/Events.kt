package com.starling

import com.facebook.react.bridge.Arguments

interface StarlingEventEmitter {
  fun sendEvent(event: StarlingEvent)
}

interface StarlingEvent {
  val eventType: String
  val data: Any?

  companion object {
    fun advertisingStarted() = object : StarlingEvent {
      override val eventType = "advertisingStarted"
      override val data = null
    }

    fun advertisingStopped(reason: String) = object : StarlingEvent {
      override val eventType = "advertisingEnded"
      override val data = reason
    }

    fun deviceConnected(deviceAddress: String) = object : StarlingEvent {
      override val eventType = "deviceConnected"
      override val data = deviceAddress
    }

    fun deviceDisconnected(deviceAddress: String) = object : StarlingEvent {
      override val eventType = "deviceDisconnected"
      override val data = deviceAddress
    }

    /*fun messageReceived(contactID: String, message: String): StarlingEvent {
      val dataMap = Arguments.createMap()
      dataMap.putString("contactID", contactID)
      dataMap.putString("body", message)

      return object : StarlingEvent {
        override val eventType = "messageReceived"
        override val data = dataMap
      }
    }*/

    /*fun messageDelivered(messageID: Long) = object : StarlingEvent {
      override val eventType = "messageDelivered"
      override val data = messageID.toDouble()
    }*/

    fun debugLog(tag: String, body: String): StarlingEvent {
      val dataMap = Arguments.createMap()
      dataMap.putString("tag", tag)
      dataMap.putString("body", body)

      return object : StarlingEvent {
        override val eventType = "debugLog"
        override val data = dataMap
      }
    }

    fun sessionEstablished(sessionID: String, contactID: String, deviceAddress: String): StarlingEvent {
      val dataMap = Arguments.createMap()
      dataMap.putString("sessionID", sessionID)
      dataMap.putString("contactID", contactID)
      dataMap.putString("deviceAddress", deviceAddress)

      return object : StarlingEvent {
        override val eventType = "sessionEstablished"
        override val data = dataMap
      }
    }

    fun sessionBroken(sessionID: String) = object : StarlingEvent {
      override val eventType = "sessionBroken"
      override val data = sessionID
    }

    fun syncStateChange(contactID: String, stateUpdate: String): StarlingEvent {
      val dataMap = Arguments.createMap()
      dataMap.putString("contactID", contactID)
      dataMap.putString("stateUpdate", stateUpdate)

      return object : StarlingEvent {
        override val eventType = "syncStateChange"
        override val data = dataMap
      }
    }
  }
}
