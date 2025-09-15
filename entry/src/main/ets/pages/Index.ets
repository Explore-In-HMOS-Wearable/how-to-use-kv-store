import KVManager from '../lib/KVManager';
import { BusinessError } from '@kit.BasicServicesKit';
import { distributedKVStore } from '@kit.ArkData';
import {
  ArcList, ArcListItem
} from '@kit.ArkUI';

const DOMAIN = 0x0000;

@Entry
@Component
struct Index {
  @State name: string = '';
  @State latestName: string = '';
  @State nameChangeHistory: Array<string> = [];
  private kvManager: KVManager = KVManager.getInstance();

  async onPageShow() {
    try {
      let store = await this.kvManager.getStore();
      store
        .on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_LOCAL,
          (data: distributedKVStore.ChangeNotification) => {
            data.insertEntries.forEach((item) => {
              if (item.key === 'name') {
                this.nameChangeHistory.push(`insert: ${item.value.value}`)
              }
            })
            data.updateEntries.forEach((item) => {
              if (item.key === 'name') {
                this.nameChangeHistory.push(`update: ${item.value.value}`)
              }
            })
            data.deleteEntries.forEach((item) => {
              if (item.key === 'name') {
                this.nameChangeHistory.push(`delete: ${item.value.value}`)
              }
            })
          });
    } catch (e) {
      let error = e as BusinessError;
      console.error(`An unexpected error occurred. code is ${error.code},message is ${error.message}`);
    }
  }

  build() {
    RelativeContainer() {
      ArcList() {
        ArcListItem() {
          Column() {
            Text('KV Store Data')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })

            Text(`Latest Name: ${this.latestName}`)
              .fontSize(18)

            TextInput({ placeholder: 'Enter name', text: this.name!! })
              .type(InputType.Normal)
              .margin({
                left: 20,
                top: 5,
                right: 20,
                bottom: 5
              })

            Row({ space: 5 }) {
              Button('Add Data', {
                type: ButtonType.Capsule,
                stateEffect: true,
                buttonStyle: ButtonStyleMode.EMPHASIZED,
                role: ButtonRole.NORMAL
              })
                .backgroundColor(0x317aff)
                .width(80)
                .height(30)
                .onClick(async () => {
                  if (this.name.length > 0) {
                    await this.kvManager.setValue('name', this.name);
                    this.name = '';
                  }
                })

              Button('Read Data', { type: ButtonType.Capsule, stateEffect: true })
                .backgroundColor(Color.Green)
                .width(80)
                .height(30)
                .onClick(async () => {
                  this.latestName = await this.kvManager.getValue('name') as string;
                })
            }

            Row() {
              Button('Delete Data', { type: ButtonType.Capsule, stateEffect: true })
                .backgroundColor(Color.Red)
                .width(90)
                .height(30)
                .onClick(async () => {
                  await this.kvManager.remove('name');
                })
            }
            .margin({ top: 10 })
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .width('100%')
          }
        }

        ArcListItem() {
          List() {
            ForEach(
              this.nameChangeHistory,
              (item: string) => {
                ListItem() {
                  Text(item)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .textAlign(TextAlign.Center)
                }
              },
              (item: string) => item
            )
          }
          .alignListItem(ListItemAlign.Center)
          .padding(20)
          .margin({ top: 20 })
          .width('100%')
          .height('100%')
        }
      }
    }
  }
}