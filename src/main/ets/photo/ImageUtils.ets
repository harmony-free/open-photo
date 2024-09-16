import { ImageGesture } from './ImageGesture'
import { Offset } from '@kit.ArkUI'

interface CropRectFace {
  offset?: Offset,
  size: Size
}

@ObservedV2
export class ImageUtils extends ImageGesture {
  protected horizontal: boolean = false
  protected vertical: boolean = false

  crop(rect: CropRectFace) {
    if (this.pixelMap != undefined) {
      let p = this.copy()
      p.cropSync({
        x: rect.offset?.x ?? 0,
        y: rect.offset?.y ?? 0,
        size: rect.size
      })
      this.pixelMap = p
    }
  }

  flip(horizontal: boolean = !this.horizontal, vertical: boolean = !this.vertical) {
    if (this.pixelMap != undefined) {
      let p = this.copy()
      p.flipSync(horizontal, vertical)
      this.pixelMap = p
      this.horizontal = horizontal
      this.vertical = vertical
    }
  }

  flipHorizontal(horizontal: boolean = !this.horizontal) {
    this.flip(horizontal, false)
  }

  flipVertical(vertical: boolean = !this.vertical) {
    this.flip(false, vertical)
  }
}
