import {
  Alert,
  PermissionsAndroid,
  Platform,
  type Permission,
  type PermissionStatus,
} from 'react-native';
import Starling from './NativeStarling';

export interface AdvertisementData {
  serviceUUID: string;
  characteristicUUID: string;
  appleBit: number;
}

export type Contact = string;

async function checkAndroidPermissions(): Promise<Permission[]> {
  if (Platform.OS !== 'android') {
    return [];
  }

  let permissions: Permission[] = [
    'android.permission.BLUETOOTH_SCAN',
    'android.permission.BLUETOOTH_CONNECT',
    'android.permission.BLUETOOTH_ADVERTISE',
  ];

  if (Platform.Version < 31) {
    permissions = permissions.concat([
      'android.permission.ACCESS_FINE_LOCATION',
    ]);
  }

  const granted = await PermissionsAndroid.requestMultiple(permissions);

  const notGranted = Object.keys(granted).filter(
    (key) =>
      ((granted as any)[key] as PermissionStatus) !==
      PermissionsAndroid.RESULTS.GRANTED
  ) as Permission[];

  return notGranted;
}

export function startAdvertising({
  serviceUUID,
  characteristicUUID,
  appleBit,
}: AdvertisementData) {
  checkAndroidPermissions().then((missingPermissions) => {
    if (missingPermissions.length === 0) {
      Starling.startAdvertising(serviceUUID, characteristicUUID, appleBit);
    } else {
      Alert.alert(
        'Permissions denied',
        `The permissions are needed in order to connect to the network: ${missingPermissions.join(
          ', '
        )}`
      );
    }
  });
}

export function stopAdvertising() {
  Starling.stopAdvertising();
}

export function sendMessage(
  contact: Contact,
  body: string,
  attachedContact: string | null | undefined
): Promise<void> {
  return Starling.sendMessage(contact, body, attachedContact ?? undefined);
}

export function startLinkSession(): Promise<string> {
  return Starling.startLinkSession();
}

export function connectLinkSession(url: string): Promise<Contact> {
  return Starling.connectLinkSession(url);
}

export function deleteContact(contact: Contact) {
  return Starling.deleteContact(contact);
}

export function newGroup(): Promise<Contact> {
  return Starling.newGroup();
}

export function joinGroup(groupSecret: string): Promise<Contact> {
  return Starling.joinGroup(groupSecret);
}

export function groupContactID(groupSecret: string): string {
  return Starling.groupContactID(groupSecret);
}

export function loadPersistedState() {
  return Starling.loadPersistedState();
}

export function deletePersistedState() {
  return Starling.deletePersistedState();
}

export function broadcastRouteRequest() {
  return Starling.broadcastRouteRequest();
}

export enum StarlingEventType {
  AdvertisingStarted = 'advertisingStarted',
  AdvertisingEnded = 'advertisingEnded',
  DeviceConnected = 'deviceConnected',
  DeviceDisconnected = 'deviceDisconnected',
  MessageReceived = 'messageReceived',
  DebugLog = 'debugLog',
  SessionEstablished = 'sessionEstablished',
  SessionBroken = 'sessionBroken',
  MessageDelivered = 'messageDelivered',
  SyncStateChange = 'syncStateChange',
}

export { Starling };
