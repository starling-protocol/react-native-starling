package com.starling

import android.util.Base64
import android.util.Log
import com.example.starling.Contact
import com.example.starling.LinkingSession
import com.example.starling.StarlingManager
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import java.lang.IllegalStateException
import java.net.URI

@ReactModule(name = StarlingModule.NAME)
class StarlingModule(reactContext: ReactApplicationContext) :
  NativeStarlingSpec(reactContext), StarlingEventEmitter {

  private val ctx: ReactApplicationContext = reactApplicationContext

  private val starling = StarlingManager(ctx, getLogger(), CallbackEvents(this))

  private var linkSession: LinkingSession? = null

  override fun getName(): String {
    return NAME
  }

  override fun startAdvertising(
    serviceUUID: String?,
    characteristicUUID: String?,
    appleBit: Double
  ) {
    if (serviceUUID == null) throw IllegalArgumentException("serviceUUID must not be null")
    if (characteristicUUID == null) throw IllegalArgumentException("characteristicUUID must not be null")

    starling.startAdvertising(serviceUUID, characteristicUUID, appleBit)
  }

  override fun stopAdvertising() {
    starling.stopAdvertising()
  }

  override fun broadcastRouteRequest() {
    starling.broadcastRouteRequest()
  }

  override fun sendMessage(
    contactID: String?,
    body: String?,
    attachedContact: String?,
    promise: Promise?
  ) {
    if (contactID == null) throw IllegalArgumentException("contact was null in sendMessage")
    if (body == null) throw IllegalArgumentException("body was null in sendMessage")

    val contact = Contact(contactID)

    try {
      starling.syncAddMessage(contact, body.toByteArray(), attachedContact?.let { Contact(it) })
      promise!!.resolve(null)
    } catch (e: Exception) {
      promise!!.reject(e)
    }
  }

  override fun newGroup(promise: Promise?) {
    try {
      val contact = starling.newGroup()
      promise!!.resolve(contact.id)
    } catch (e: Exception) {
      promise!!.reject(e)
    }
  }

  override fun joinGroup(groupSecret: String?, promise: Promise?) {
    try {
      val secret = Base64.decode(groupSecret!!, Base64.DEFAULT)
      val contact = starling.joinGroup(secret)
      promise!!.resolve(contact.id)
    } catch (e: Exception) {
      promise!!.reject(e)
    }
  }

  override fun groupContactID(groupSecret: String?): String {
    val secret = Base64.decode(groupSecret!!, Base64.DEFAULT)
    return starling.groupContact(secret).id
  }

  override fun startLinkSession(promise: Promise?) {
    try {
      val session = starling.startLinkSession()
      this.linkSession = session

      val base64 = Base64.encodeToString(session.share, Base64.URL_SAFE)
      promise!!.resolve("starling://$base64")
    } catch (e: Exception) {
      promise!!.reject(e)
    }
  }

  override fun connectLinkSession(url: String?, promise: Promise?) {
    try {
      val linkSession = this.linkSession
        ?: throw IllegalStateException("connectLinkSession should be called after startLinkSession")
      this.linkSession = null

      val uri = URI(url!!)
      val remoteKey = Base64.decode(uri.authority, Base64.URL_SAFE)
      val contact = starling.connectLinkSession(linkSession, remoteKey)

      promise!!.resolve(contact.id)
    } catch (e: Exception) {
      promise!!.reject(e)
    }
  }

  override fun deleteContact(contactID: String?) {
    starling.deleteContact(Contact(contactID!!))
  }

  override fun loadPersistedState() {
    starling.loadPersistedState()
  }

  override fun deletePersistedState() {
    starling.deletePersistedState()
  }

  override fun sendEvent(event: StarlingEvent) {
    if (event.eventType != "debugLog") {
      Log.d(TAG, "sending event to UI: ${event.eventType}")
    }

    ctx.emitDeviceEvent(event.eventType, event.data)
  }

  override fun addListener(eventType: String?) {}

  override fun removeListeners(count: Double) {}

  companion object {
    const val NAME = "Starling"
    const val TAG = "starling-module"
  }
}

fun StarlingModule.getLogger() = object : com.example.starling.Logger {
  fun logEvent(priority: Int, tag: String, msg: String) {
    Log.println(priority, tag, msg)

    val priorityStr = when (priority) {
      Log.DEBUG -> "DEBUG"
      Log.INFO -> "INFO"
      Log.WARN -> "WARN"
      Log.ERROR -> "ERROR"
      else -> "???"
    }

    sendEvent(StarlingEvent.debugLog("$priorityStr $tag", msg))
  }

  override fun log(priority: Int, tag: String, message: String) {
    logEvent(priority, tag, message)
  }

  override fun logException(tag: String, message: String, exception: Exception) {
    logEvent(Log.WARN, tag, "CAUGHT: ${message} ${exception.localizedMessage}")
  }
}
