import { image } from '@kit.ImageKit';
import { http } from '@kit.NetworkKit';
import { display, matrix4, router } from '@kit.ArkUI';
import { Vec2 } from '@kit.ArkGraphics3D';

import { PhotoUtils } from './PhotoManage';

export enum OpenImageType {
  uri,
  src,
  url,
}

export interface OpenImageQueryFace {
  src: string
  type: OpenImageType
}

class HttpUtil {
  async download(url: string): Promise<ArrayBuffer> {
    return new Promise<ArrayBuffer>((res, rej) => {
      http.createHttp().request(url).then((resp) => {
        res(resp.result as ArrayBuffer)
      })
    })
  }
}


@Entry({ routeName: 'photoManage/OpenImage' })
@Component
struct OpenImage {
  private query: OpenImageQueryFace = router.getParams() as OpenImageQueryFace
  private path = PhotoUtils.copyUri(this.query.src)
  private imageSource: image.ImageSource = image.createImageSource(this.path)
  private imageSize: Size = { width: 0, height: 0 }
  private scaleRadius: number = 1.0
  private pixels: number = 1.0
  private offsetV: Vec2 = { x: 0, y: 0 }
  private oldMatrix: matrix4.Matrix4Transit = matrix4.identity()
  @State pixelMap: image.PixelMap = this.imageSource.createPixelMapSync()
  @State aspect: number = 1.0
  @State matrix: matrix4.Matrix4Transit = matrix4.identity()

  aboutToAppear(): void {
    this.pixels = display.getDefaultDisplaySync().densityPixels
    this.setImageSource()
  }

  async setImageSource() {
    if (this.query.type == OpenImageType.uri) {
      let path = PhotoUtils.copyUri(this.query.src)
      this.imageSource = image.createImageSource(path)
    } else if (this.query.type == OpenImageType.url) {
      await this.setUrl(this.query.src as string)
    } else if (this.query.type == OpenImageType.src) {
      this.imageSource = image.createImageSource(this.query.src as string)
    }
    this.setInfo()
  }

  async setUrl(url: string) {
    let buf = await new HttpUtil().download(url)
    this.imageSource = image.createImageSource(buf)
  }

  setInfo() {
    this.pixelMap = this.imageSource!.createPixelMapSync()
    this.imageSize = this.imageSource!.getImageInfoSync().size
    this.aspect = this.imageSize.width / this.imageSize.height
  }

  build() {
    Row() {
      Column() {
        Image(this.pixelMap)
          .width('100%')
          .aspectRatio(this.aspect)
          .transform(this.matrix)
          .objectFit(ImageFit.Cover)
          .autoResize(false)
          .gesture(
            GestureGroup(GestureMode.Exclusive,
              PinchGesture({ fingers: 2 })
                .onActionStart(() => {
                  this.oldMatrix = this.matrix.copy()
                })
                .onActionUpdate((event) => {
                  this.oldMatrix.copy()
                  let wid = event.target.area.width as number / 2
                  let hei = event.target.area.height as number / 2
                  let cenX = wid - event.pinchCenterX + this.offsetV.x
                  let cenY = hei - event.pinchCenterY + this.offsetV.y
                  this.matrix.scale({
                    x: this.scaleRadius,
                    y: this.scaleRadius,
                    centerX: cenX * this.pixels,
                    centerY: cenY * this.pixels
                  })
                }),
              LongPressGesture({ repeat: true })
                .onAction((event: GestureEvent) => {

                }),
              TapGesture({ count: 2, fingers: 1 })
                .onAction((event) => {
                  let wid = event.target.area.width as number / 2
                  let hei = event.target.area.height as number / 2
                  let cenX = wid - event.fingerList[0].localX + this.offsetV.x
                  let cenY = hei - event.fingerList[0].localY + this.offsetV.y
                  if (this.scaleRadius == 1) {
                    this.matrix.scale({
                      x: this.scaleRadius,
                      y: this.scaleRadius,
                      centerX: cenX * this.pixels,
                      centerY: cenY * this.pixels
                    })
                    this.scaleRadius = 2
                  } else {
                    this.matrix = matrix4.identity()
                    this.scaleRadius = 1
                    this.offsetV = { x: 0, y: 0 }
                  }
                }),
              PanGesture({ fingers: 1 })
                .onActionStart(() => {
                  this.offsetV = { x: 0, y: 0 }
                })
                .onActionUpdate((event) => {
                  this.matrix.translate({ x: event.offsetX - this.offsetV.x, y: event.offsetY - this.offsetV.y })
                  this.offsetV = { x: event.offsetX, y: event.offsetY }
                }),
              RotationGesture({ fingers: 2 })
                .onActionUpdate(() => {

                })
                .onActionEnd(() => {


                })
            )
          )
      }
      .width('100%')
    }
    .height('100%')
  }
}
