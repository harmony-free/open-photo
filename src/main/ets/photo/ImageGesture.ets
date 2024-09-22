import { ImageBase } from './ImageBase'
import { matrix4 } from '@kit.ArkUI'

interface PinchGestureFace {
  onPinchStart(event: GestureEvent): void

  onPinchUpdate(event: GestureEvent): void

  onPinchEnd(event: GestureEvent): void
}

interface LongPressGestureFace {
  onLongPress(event: GestureEvent): void
}

interface TapGestureFace {
  onTap(event: GestureEvent): void

  onDouble(event: GestureEvent): void
}

interface PanGestureFace {
  onPanStart(event: GestureEvent): void

  onPanUpdate(event: GestureEvent): void

  onPanEnd(event: GestureEvent): void
}

interface RotationGestureFace {
  onRotationStart(event: GestureEvent): void

  onRotationUpdate(event: GestureEvent): void

  onRotationEnd(event: GestureEvent): void
}

interface GestureFace extends PinchGestureFace, LongPressGestureFace, TapGestureFace, PanGestureFace, RotationGestureFace {}

export class ImageGesture extends ImageBase implements GestureFace {
  onPinchStart(event: GestureEvent): void {
    this.oldMatrix = this.matrix.copy()
  }

  onPinchUpdate(event: GestureEvent): void {
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
  }

  onPinchEnd(event: GestureEvent): void {
    this.ratio = this.ratio * event.scale
    this.setReset(event)
  }

  onLongPress(event: GestureEvent): void {

  }

  onTap(event: GestureEvent): void {

  }

  onDouble(event: GestureEvent): void {
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
      this.matrix = this.matrix.copy()
    } else {
      this.matrix = matrix4.identity().copy()
      this.offsetV.x = 0
      this.offsetV.y = 0
      this.ratio = 1
    }
  }

  onPanStart(event: GestureEvent): void {
    this.offsetV = { x: 0, y: 0 }
  }

  onPanUpdate(event: GestureEvent): void {
    let offX = event.offsetX - this.offsetV.x
    let offY = event.offsetY - this.offsetV.y
    this.matrix.translate({ x: offX * this.ratio * 3.25, y: offY * this.ratio * 3.25 })
    this.offsetV.x = event.offsetX
    this.offsetV.y = event.offsetY
    this.matrix = this.matrix.copy()
  }

  onPanEnd(event: GestureEvent): void {
    this.setReset(event)
  }

  onRotationStart(event: GestureEvent): void {
    this.oldMatrix = this.matrix.copy()
  }

  onRotationUpdate(event: GestureEvent): void {
    let matrix = this.oldMatrix.copy()
    matrix.rotate({
      angle: event.angle,
      z: 1,
    })
    this.matrix = matrix
  }

  onRotationEnd(event: GestureEvent): void {
    this.matrix.rotate({
      angle: -event.angle,
      z: 1,
    })
    // let angle = event.angle % 90
    if (event.angle > 45) {
      // angle = 90 - angle
      this.angle += 90
      this.isWidth = !this.isWidth
      if (this.isWidth) {
        this.aspect = this.imageSize.width / this.imageSize.height
      } else {
        this.aspect = this.imageSize.height / this.imageSize.width
      }
      this.pixelMap = this.copy()
    } else {
      // angle = -angle
    }
    this.matrix = this.matrix.copy()
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
}