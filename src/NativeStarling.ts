import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  startAdvertising(
    serviceUUID: string,
    characteristicUUID: string,
    appleBit: number
  ): void;
  stopAdvertising(): void;

  broadcastRouteRequest(): void;

  sendMessage(
    contactID: string,
    body: string,
    attachedContact: string | undefined
  ): Promise<void>;

  newGroup(): Promise<string>;
  joinGroup(groupSecret: string): Promise<string>;
  groupContactID(groupSecret: string): string;

  startLinkSession(): Promise<string>;
  connectLinkSession(url: string): Promise<string>;
  deleteContact(contactID: string): void;

  loadPersistedState(): void;
  deletePersistedState(): void;

  // Event emitters provided by react-native
  addListener: (eventType: string) => void;
  removeListeners: (count: number) => void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('Starling');
