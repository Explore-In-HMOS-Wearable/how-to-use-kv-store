import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

const STORE_ID = 'storeID';

export default class KVManager {
  private static instance: KVManager;
  private kvManager: distributedKVStore.KVManager;
  private kvStore: distributedKVStore.SingleKVStore | undefined = undefined;

  constructor(kvManager: distributedKVStore.KVManager) {
    this.kvManager = kvManager;
  }

  static getInstance(kvManager?: distributedKVStore.KVManager): KVManager {
    if (!KVManager.instance && kvManager) {
      KVManager.instance = new KVManager(kvManager!);
    }

    return KVManager.instance;
  }

  async createStore() {
    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: false,
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      securityLevel: distributedKVStore.SecurityLevel.S3
    };

    try {
      this.kvStore = await this.kvManager.getKVStore(STORE_ID, options);
    } catch (e) {
      let error = e as BusinessError;
      console.error(`Failed to create KVManager. Code: ${error.code}, message: ${error.message}`);
    }
  }

  async setValue(key: string, value: string) {
    try {
      await this.kvStore?.put(key, value);
    } catch (e) {
      let error = e as BusinessError;
      console.error(`An unexpected error occurred. Code: ${error.code}, message: ${error.message}`);
    }
  }

  async getValue(key: string) {
    try {
      return await this.kvStore?.get(key);
    } catch (e) {
      let err = e as BusinessError;
      console.log(`Error occurred. Code: ${err.code}, message: ${err.message}`)
      return '';
    }
  }

  async remove(key: string) {
    try {
      this.kvStore?.delete(key, (err) => {
        if (err !== undefined) {
          console.error(`Failed to delete data. Code: ${err.code}, message: ${err.message}`);
          return;
        }
        console.info('Succeeded in deleting data.');
      });
    } catch (e) {
      let error = e as BusinessError;
      console.log(`Error ${error.message}`);
    }
  }

  async getStore(): Promise<distributedKVStore.SingleKVStore> {
    if (!this.kvStore) {
      await this.createStore();
    }
    return this.kvStore!;
  }

  async deleteStore() {
    this.kvStore = undefined;
    await this.kvManager.deleteKVStore('com.hmosdemos.kvstore', STORE_ID);
  }
}