import { matrix4 } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'
import { Vec2 } from '@kit.ArkGraphics3D'
import { NavBar } from '@free/global'
import { ImageTools } from '../photo/ImageTools'

@Builder
export function OpenImageBuilder(o: object) {
  NavDestination() {
    OpenImage({ src: o['src'] })
  }.hideTitleBar(true)
}

@Entry
@Component
export struct OpenImage {
  private src: string = ""
  private imageSource: image.ImageSource = image.createImageSource(new ArrayBuffer(96))
  private imageSize: image.Size = { width: 4, height: 6 }
  private ratio: number = 1.0
  private offsetV: Vec2 = { x: 0, y: 0 }
  private oldMatrix: matrix4.Matrix4Transit = matrix4.identity().copy();
  @State aspect: number = this.imageSize.width / this.imageSize.height
  @State matrix: matrix4.Matrix4Transit = matrix4.identity().copy();
  @State pixelMap: image.PixelMap = this.imageSource.createPixelMapSync({ editable: true })
  @State angle: number = 0.0
  @State isWidth: boolean = true
  @State sizeWidth: Length = '100%'
  @State sizeHeight: Length = '100%'

  @Builder
  rightBuilder() {
    Image($r('sys.symbol.delete_left'))
  }

  set(index: number, value: number) {
    this.matrix['matrix4x4'][index] = value
  }

  get(index: number): number {
    return this.matrix['matrix4x4'][index]
  }

  getLocal(index: number): number {
    return this.matrix['matrix4x4'][index] / this.ratio / 4
  }

  setReset(event: GestureEvent) {
    if (this.ratio < 1) {
      this.matrix = matrix4.identity().copy()
      this.offsetV.x = 0
      this.offsetV.y = 0
      this.ratio = 1
      return
    } else if (this.ratio >= 5) {
      this.ratio = 5
    }
    let offX = this.get(12)
    let offY = this.get(13)
    let wid = event.target.area.width as number
    let hei = event.target.area.height as number
    wid = wid / 2 * (this.ratio - 1) * 3.25
    hei = hei / 2 * (this.ratio - 1) * 3.25
    if (offX >= wid) {
      this.set(12, wid)
      this.offsetV.x = wid
    }
    if (offY >= hei) {
      this.set(13, hei)
      this.offsetV.y = hei
    }
    if (offX <= -wid) {
      this.set(12, -wid)
      this.offsetV.x = -wid
    }
    if (offY <= -hei) {
      this.set(13, -hei)
      this.offsetV.y = -hei
    }
    this.matrix = this.matrix.copy()

  }

  aboutToAppear(): void {
    new ImageTools().read(this.src).then((file) => {
      this.imageSource = image.createImageSource(this.src)
      this.pixelMap = this.imageSource.createPixelMapSync();
      this.imageSize = this.imageSource.getImageInfoSync().size
      this.aspect = this.imageSize.width / this.imageSize.height
    })
  }

  build() {
    Stack() {
      Image(this.pixelMap)
        .width("100%")
        .aspectRatio(this.aspect)
        .objectFit(ImageFit.Fill)
        .draggable(false)
        .transform(this.matrix)
        .autoResize(false)
        .gesture(
          GestureGroup(GestureMode.Exclusive,
            PinchGesture({ fingers: 2 })
              .onActionStart(() => {
                this.oldMatrix = this.matrix.copy()
              })
              .onActionUpdate((event: GestureEvent) => {
                let cenX = event.target.area.width as number / 2
                let cenY = event.target.area.height as number / 2
                let offX = event.pinchCenterX - cenX + this.offsetV.x
                let offY = event.pinchCenterY - cenY + this.offsetV.y
                let old = this.oldMatrix.copy()
                let maxRatio = this.ratio * event.scale
                if (maxRatio > 5) {
                  event.scale = 5 / this.ratio
                }
                old.scale({
                  x: event.scale,
                  y: event.scale,
                  centerX: offX * 3.25,
                  centerY: offY * 3.25,
                })
                this.matrix = old
              })
              .onActionEnd((event: GestureEvent) => {
                this.ratio = this.ratio * event.scale
                this.setReset(event)
              }),
            LongPressGesture({ repeat: true })
              .onAction((event: GestureEvent) => {
                if (event.repeat) {
                  console.log("LongPressGesture.start")
                }
              }),
            TapGesture({ count: 2 })
              .onAction((event: TapGestureEvent) => {
                let cenX = event.target.area.width as number / 2
                let cenY = event.target.area.height as number / 2
                let offX = event.fingerList[0].localX - cenX + this.offsetV.x
                let offY = event.fingerList[0].localY - cenY + this.offsetV.y
                if (this.ratio == 1) {
                  this.ratio = 2
                  this.matrix.scale({
                    x: this.ratio,
                    y: this.ratio,
                    centerX: offX * 3.25,
                    centerY: offY * 3.25,
                  })
                } else {
                  this.matrix = matrix4.identity().copy()
                  this.offsetV.x = 0
                  this.offsetV.y = 0
                  this.ratio = 1
                }
              }),
            TapGesture({ count: 1, fingers: 1 })
              .onAction(() => {

              }),
            PanGesture({ fingers: 1 })
              .onActionStart(() => {
                this.offsetV.x = 0
                this.offsetV.y = 0
              })
              .onActionUpdate((event: GestureEvent) => {
                let offX = event.offsetX - this.offsetV.x
                let offY = event.offsetY - this.offsetV.y
                console.log(`${this.angle}--${event.offsetX}:${event.offsetY}`)
                this.matrix.translate({ x: offX * this.ratio * 3.25, y: offY * this.ratio * 3.25 })
                this.offsetV.x = event.offsetX
                this.offsetV.y = event.offsetY
              }).onActionEnd((event) => {
              this.setReset(event)

            }),

            RotationGesture({ fingers: 2 })
              .onActionStart((event: GestureEvent | undefined) => {
                this.oldMatrix = this.matrix.copy()
                console.info('RotationGesture is onActionStart');
              })// 当旋转手势生效时，通过旋转手势的回调函数获取旋转角度，从而修改组件的旋转角度
              .onActionUpdate((event: GestureEvent) => {
                let matrix = this.oldMatrix.copy()
                matrix.rotate({
                  angle: event.angle,
                  z: 1,
                })
                this.matrix = matrix
              })// 当旋转结束抬手时，固定组件在旋转结束时的角度
              .onActionEnd((event) => {
                this.matrix.rotate({
                  angle: -event.angle,
                  z: 1,
                })
                let angle = event.angle % 90
                if (angle > 45) {
                  angle = 90 - angle
                  this.angle += 90
                  this.isWidth = !this.isWidth
                  if (this.isWidth) {
                    this.aspect = this.imageSize.width / this.imageSize.height
                  } else {
                    this.aspect = this.imageSize.height / this.imageSize.width
                  }
                  this.pixelMap = this.imageSource.createPixelMapSync({ rotate: this.angle % 360 })
                } else {
                  angle = -angle
                }

              })
          )
        )
      NavBar({ backColor: 0x60EEEEEE }).position({ x: 0, y: 0 })
    }.width('100%').height('100%').backgroundColor(Color.Black)
  }
}