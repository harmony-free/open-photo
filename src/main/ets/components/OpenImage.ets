import { NavBar } from '@free/global'
import { ImageView } from './ImageView'
import { ImageUtils } from '../photo/ImageUtils'
import { GestureDirectionType } from '../photo/ImageGesture'

export interface OpenImageParams {
  data: string
}

@Builder
export function OpenImageBuilder(p: object) {
  NavDestination() {
    OpenImage({ src: (p as OpenImageParams).data })
  }.hideTitleBar(true)
}

@Entry({ routeName: 'photoManage/OpenImage' })
@Component
export struct OpenImage {
  @State src: string =
    "https://ts1.cn.mm.bing.net/th/id/R-C.e095e6cf39baa7d349d45c4c1c6f5f78?rik=%2fJXDWPsR3VaxVw&riu=http%3a%2f%2fimg.sj33.cn%2fuploads%2fallimg%2f200912%2f20091223150330493.jpg&ehk=TJoSjF68pWq6vl0NHUl8RTUroI2xHptF83Im%2b0RVWnc%3d&risl=&pid=ImgRaw&r=0"

  @Builder
  rightBuilder() {
    Image($r('sys.symbol.delete_left'))
  }

  build() {
    Stack() {
      ImageView({
        src: this.src,
      }).width("100%")
      NavBar({
        backColor: Color.Transparent,
        textColor: Color.White,
      }).position({ top: 0 }).backgroundBlurStyle(BlurStyle.Thin,
        { colorMode: ThemeColorMode.DARK, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
    }.width('100%').height('100%').backgroundColor("#ff323131")
  }
}