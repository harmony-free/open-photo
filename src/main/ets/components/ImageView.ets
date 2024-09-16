import { ImageUtils } from '../photo/ImageUtils'

@Extend(Image)
function preview(image: ImageUtils) {
  .objectFit(ImageFit.Fill)
  .draggable(false)
  .autoResize(false)
  .aspectRatio(image.aspect)
  .transform(image.matrix)
  .gesture(
    GestureGroup(
      GestureMode.Exclusive,
      PinchGesture({ fingers: 2 })
        .onActionStart((e) => image.onPinchStart(e))
        .onActionUpdate((e) => image.onPinchUpdate(e))
        .onActionEnd((e) => image.onPinchEnd(e)),
      LongPressGesture({ repeat: true })
        .onAction((e) => image.onLongPress(e)),
      TapGesture({ count: 2, fingers: 1 })
        .onAction((e) => image.onDouble(e)),
      TapGesture({ count: 1, fingers: 1 })
        .onAction((e) => image.onTap(e)),
      PanGesture({ fingers: 1 })
        .onActionStart((e) => image.onPanStart(e))
        .onActionUpdate((e) => image.onPanUpdate(e))
        .onActionEnd((e) => image.onPanEnd(e)),
      RotationGesture({ fingers: 2 })
        .onActionStart((e) => image.onRotationStart(e))
        .onActionUpdate((e) => image.onRotationUpdate(e))
        .onActionEnd((e) => image.onRotationEnd(e)),
    )
  )
}

@ComponentV2
export struct ImageView {
  @Param src: string = ""
  @Param image: ImageUtils = new ImageUtils(this.src)

  build() {
    Image(this.image.pixelMap)
      .width("100%")
      .preview(this.image)
  }
}