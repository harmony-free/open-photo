import { photoAccessHelper } from '@kit.MediaLibraryKit'
import router from '@ohos.router'
import { PhotoManage } from '../photo/PhotoManage'

@Observed
class ItemModel {
  title: string = ""
  text: string = ""
  select: boolean = false
  asset: photoAccessHelper.PhotoAsset

  constructor(asset: photoAccessHelper.PhotoAsset) {
    this.asset = asset
  }
}

export interface PhotoPageQuery {
  max: number
  min: number
  isEdit: boolean
  isCamera: boolean
  preview: boolean
  isOriginal: boolean
}


@Entry({ routeName: 'photoManage/PhotoPage' })
@Component
export struct PhotoPage {
  private query: PhotoPageQuery = router.getParams() as PhotoPageQuery
  private pm: PhotoManage = new PhotoManage()
  @State photos: ItemModel[] = []
  @State selectList: ItemModel[] = []
  @State selectCount: number = 0
  @State list: number[] = []
  @StorageProp('topHeight') top: number = 40
  @StorageProp('bottomHeight') bottom: number = 0

  aboutToAppear(): void {

    // this.pm.requestPermissions('ohos.permission.READ_IMAGEVIDEO','ohos.permission.WRITE_IMAGEVIDEO')

    if (this.query == undefined) {
      this.query = {
        isEdit: true,
        preview: true,
      } as PhotoPageQuery
    }
    console.log(JSON.stringify(this.query))

    this.pm.init().then((list) => {
      list.forEach((asset) => {
        this.photos.push(new ItemModel(asset))
        this.photos.push(new ItemModel(asset))
      })
    })
  }

  build() {
    Stack() {
      Grid() {
        if (this.query?.isCamera) {
          GridItem() {
            Text() {
              SymbolSpan($r('sys.symbol.camera'))
            }
            .fontColor(0xCCCCCC)
            .fontSize(50)
            .width('100%')
            .aspectRatio(1)
            .textAlign(TextAlign.Center)
            .backgroundColor(0x999999)
          }.onClick(() => {
            console.log("打开相机拍照")
          })
        }
        ForEach(this.photos, (item: ItemModel, index: number) => {
          GridItem() {
            PhotoItem({
              item: item,
              index: index,
              list: this.list,
              selectCount: this.selectCount,
              max: this.query.max
            })
          }
        }, (item: ItemModel) => item.text)
      }
      .width('100%')
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(2)
      .rowsGap(2)
      .padding({ top: 84, bottom: 89 })

      Stack() {
        Text() {
          SymbolSpan($r('sys.symbol.xmark'))
        }
        .width(44)
        .height(44)
        .fontSize(20)
        .position({ left: 0, top: 0 })
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          router.back()
        })

        Text('相册').height(44).fontColor(Color.White)
      }
      .width('100%')
      .padding({ top: 40 })
      .position({ top: 0 })
      .backgroundBlurStyle(BlurStyle.Thin,
        { colorMode: ThemeColorMode.DARK, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })

      Stack() {
        Text('预览')
          .height(49)
          .position({ left: 0, top: 0 })
          .padding({ left: 10, right: 10 })
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)

        Text('原图').height(49).fontColor(Color.White)

        Text('发送')
          .position({ right: 0, top: 0 })
          .padding({
            left: 10,
            right: 10,
            top: 5,
            bottom: 5
          })
          .borderRadius(5)
          .fontSize(13)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.Green)
      }
      .width('100%')
      .padding({ bottom: 40 })
      .position({ bottom: 0 })
      .backgroundBlurStyle(BlurStyle.Thin,
        { colorMode: ThemeColorMode.DARK, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
    }
  }
}

@Component
struct PhotoItem {
  @ObjectLink item: ItemModel
  @Prop index: number
  @Link selectCount: number
  @Link list: number[]
  @Prop max: number

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Image(this.item.asset.uri).width('100%').onClick(() => {
        router.pushNamedRoute({
          name: 'photoManage/OpenImage', params: {
            src: this.item.asset.uri,
            // type: OpenImageType.uri,
          }
        })
      })
      if (this.item.select) {
        Text(`${this.list.indexOf(this.index) + 1}`)
          .padding({ left: 5, top: 5 })
          .fontColor(Color.White)
          .width('100%')
          .height('100%')
          .backgroundColor(0x60000000)
          .align(Alignment.TopEnd)
          .enabled(false)
      }

      Text() {
        SymbolSpan(this.item.select ? $r('sys.symbol.checkmark_circle_fill') : $r('sys.symbol.circle'))
      }
      .margin({ right: 5, top: 5 })
      .fontColor(this.item.select ? 0x25BD04 : 0xFFFFFF)
      .fontSize(25)
      .onClick(() => {
        let isOn = !this.item.select
        if (this.max != 0 && this.selectCount >= this.max && isOn) {
          this.item.select = !isOn
          return
        } else {
          this.item.select = isOn
        }
        if (isOn) {
          this.list.push(this.index)
          this.selectCount += 1
        } else {
          let index = this.list.indexOf(this.index)
          this.list.splice(index, 1)
          this.selectCount -= 1
        }
      })
    }
    .width('100%')
    .aspectRatio(1)
    .backgroundColor(Color.Red)
  }
}
