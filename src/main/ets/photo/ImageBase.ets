import { global } from '@free/global'
import { ImageTools, ImageType } from './ImageTools'
import { image } from '@kit.ImageKit'
import { Vec2 } from '@kit.ArkGraphics3D'
import { matrix4, promptAction } from '@kit.ArkUI'

@ObservedV2
export class ImageBase {
  protected name: string = global.generateUUID()
  protected imageTools: ImageTools = new ImageTools(this.name)
  protected imageSource!: image.ImageSource
  public imageSize: image.Size = { width: 4, height: 6 }
  protected offsetV: Vec2 = { x: 0, y: 0 }
  protected ratio: number = 1.0
  protected oldMatrix: matrix4.Matrix4Transit = matrix4.identity().copy();
  protected isWidth: boolean = true
  protected angle: number = 0.0
  @Trace pixelMap!: image.PixelMap
  @Trace aspect: number = this.imageSize.width / this.imageSize.height
  @Trace matrix: matrix4.Matrix4Transit

  constructor(src: ImageType) {
    this.matrix = matrix4.identity().copy();
    this.load(src)
  }

  uri(): string {
    return this.imageTools.getPath()
  }

  load(src: ImageType) {
    this.imageTools.read(src).then((file) => {
      this.imageSource = this.imageTools.toSource()
      this.pixelMap = this.imageSource.createPixelMapSync()
      this.imageSize = this.pixelMap.getImageInfoSync().size
      this.aspect = this.imageSize.width / this.imageSize.height
    }).catch((err: Error) => {
      promptAction.showToast({ message: err.message })
    })
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

  copy(): image.PixelMap {
    return this.imageSource.createPixelMapSync({ rotate: this.angle % 360 })
  }
}