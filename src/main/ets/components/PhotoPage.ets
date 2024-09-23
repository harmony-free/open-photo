import { global, NavBar, router } from '@free/global'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { PhotoManage } from '../photo/PhotoManage'
import { OpenImageParams } from './OpenImage'

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

@Builder
export function PhotoPageBuilder(o: object) {
  NavDestination() {
    PhotoPage()
  }.hideTitleBar(true)
}


@Entry({ routeName: 'photoManage/PhotoPage' })
@Component
export struct PhotoPage {
  private query: PhotoPageQuery = {
    isEdit: true,
    preview: true,
    isCamera: true,
  } as PhotoPageQuery
  private pm: PhotoManage = new PhotoManage()
  @State photos: ItemModel[] = []
  @State selectList: ItemModel[] = []
  @State selectCount: number = 0
  @State list: number[] = []
  @State isOriginal: boolean = false

  aboutToAppear(): void {
    global.setBarContentColor("#FFFFFF")
    this.upData()
  }

  upData() {
    this.photos = []
    this.pm.readAll().then((list) => {
      list.forEach((asset) => {
        this.photos.push(new ItemModel(asset))
      })
    })
  }

  aboutToDisappear(): void {
    global.setBarContentColor("#000000")
  }

  byte(): string {
    let byte = ""
    this.selectList.forEach((item) => {
    })

    return byte
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
            this.pm.cameraPhoto.camera(getContext()).then(() => {
              this.upData()
            })
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
      .padding({
        top: 84,
        bottom: 89,
        left: 2,
        right: 2
      })
      .backgroundColor("#ff323131")

      NavBar({
        title: "相册",
        backColor: Color.Transparent,
        textColor: Color.White,
      })
        .position({ top: 0 })
        .backgroundBlurStyle(BlurStyle.Thin,
          { colorMode: ThemeColorMode.DARK, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })

      Row() {
        if (this.selectCount == 0) {
          Text('预览')
            .height(49)
            .fontColor('#ffa9aba9')
        } else {
          Text('预览')
            .height(49)
            .fontColor(Color.White)
        }


        // Text() {
        //   SymbolSpan(this.isOriginal ? $r('sys.symbol.checkmark_circle_fill') : $r('sys.symbol.circle')).fontSize(17)
        //   Span(" 原图")
        //   // Span(`共${this.byte()}`)
        // }.height(49).fontColor(Color.White).onClick(() => {
        //   this.isOriginal = !this.isOriginal
        // }).fontColor(this.isOriginal ? '#04BE02' : 0xFFFFFF)

        if (this.selectCount == 0) {
          Text("发送")
            .padding({
              left: 10,
              right: 10,
              top: 7,
              bottom: 7
            })
            .borderRadius(5)
            .fontSize(13)
            .fontColor('#ffa9aba9')
            .backgroundColor('#ff303030')
        } else {
          Text(this.selectCount == 0 ? "发送" : `发送(${this.selectCount})`)
            .padding({
              left: 10,
              right: 10,
              top: 7,
              bottom: 7
            })
            .borderRadius(5)
            .fontSize(13)
            .fontColor(Color.White)
            .backgroundColor('#04BE02')
            .onClick(() => {
              this.photos.forEach((p, i) => {
                if (this.list.indexOf(i) != -1) {
                  this.selectList.push(p)
                }
              })

              router.back(this.selectList)
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: global.bottom + 20, left: 10, right: 10 })
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
      Image(this.item.asset.uri).objectFit(ImageFit.Cover).width('100%').aspectRatio(1).onClick(() => {
        router.push("openImage", { data: this.item.asset.uri } as OpenImageParams)
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
      .fontColor(this.item.select ? '#04BE02' : 0xFFFFFF)
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
  }
}
