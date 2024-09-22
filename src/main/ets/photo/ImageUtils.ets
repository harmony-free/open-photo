import { ImageGesture } from './ImageGesture'
import { matrix4, Offset } from '@kit.ArkUI'
import { image } from '@kit.ImageKit'

interface CropRectFace {
  offset?: Offset,
  size: Size
}

interface MatrixPixelMap {
  pixelMap: image.PixelMap
  matrix: matrix4.Matrix4Transit
  horizontal: boolean
  vertical: boolean
}

@ObservedV2
export class ImageUtils extends ImageGesture {
  private oldList: Array<MatrixPixelMap> = []
  protected horizontal: boolean = false
  protected vertical: boolean = false

  private reRead() {
    this.write(this.read())
  }

  private read(): ArrayBuffer {
    let buf = new ArrayBuffer(this.pixelMap.getPixelBytesNumber())
    this.pixelMap.readPixelsToBufferSync(buf)
    return buf
  }

  private write(buf: ArrayBuffer) {
    this.imageTools.setBuffer(buf)
    this.imageSource = this.imageTools.toSource()
    this.pixelMap = this.copy()
  }

  crop(rect: CropRectFace) {
    if (this.pixelMap != undefined) {
      let p = this.clone()
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
      let p = this.clone()
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

  clone(): image.PixelMap {
    this.oldList.push({
      matrix: this.matrix,
      pixelMap: this.pixelMap,
      horizontal: this.horizontal,
      vertical: this.vertical
    })
    return this.copy()
  }

  back() {
    let map = this.oldList.pop()
    if (map != undefined) {
      this.pixelMap = map.pixelMap
      this.matrix = map.matrix
      this.vertical = map.vertical
      this.horizontal = map.horizontal
    }
  }


  clear() {

  }
}
