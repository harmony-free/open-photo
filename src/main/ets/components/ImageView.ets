import { ImageUtils } from '../photo/ImageUtils'
import { visionImageAnalyzer } from '@kit.VisionKit'
import { BusinessError } from '@kit.BasicServicesKit'

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
  private visionImageAnalyzerController: visionImageAnalyzer.VisionImageAnalyzerController =
    new visionImageAnalyzer.VisionImageAnalyzerController()

  aboutToAppear(): void {
    this.visionImageAnalyzerController?.setAIButtonVisibility(true)
    this.visionImageAnalyzerController.on('aiButtonStatusChange',
      (aiButtonState: visionImageAnalyzer.AIButtonStatus) => {
        console.info("DEMO_TAG", `aiButtonStatusChange result: ${JSON.stringify(aiButtonState)}`)
      })
    this.visionImageAnalyzerController.on('imageAnalyzerVisibilityChange',
      (visibility: visionImageAnalyzer.ImageAnalyzerVisibility) => {
        console.info("DEMO_TAG", `imageAnalyzerVisibilityChange result: ${JSON.stringify(visibility)}`)
      })
    this.visionImageAnalyzerController.on('textAnalysis', (text: string) => {
      console.info("DEMO_TAG", `textAnalysis result: ${JSON.stringify(text)}`)
    })
    this.visionImageAnalyzerController.on('selectedTextChange', (selectedText: string) => {
      console.info("DEMO_TAG", `selectedTextChange result: ${JSON.stringify(selectedText)}`)
    })
    this.visionImageAnalyzerController.on('selectedSubjectsChange', (subjects: visionImageAnalyzer.Subject[]) => {
      console.info("DEMO_TAG", `selectedSubjectsChange result: ${JSON.stringify(subjects)}`)
    })
    this.visionImageAnalyzerController.on('analyzerFailed', (error: BusinessError) => {
      console.error("DEMO_TAG", `analyzerFailed result: ${JSON.stringify(error)}`)
    })
  }

  aboutToDisappear(): void {
    this.visionImageAnalyzerController.off('aiButtonStatusChange')
    this.visionImageAnalyzerController.off('imageAnalyzerVisibilityChange')
    this.visionImageAnalyzerController.off('textAnalysis')
    this.visionImageAnalyzerController.off('selectedTextChange')
    this.visionImageAnalyzerController.off('subjectAnalysis')
    this.visionImageAnalyzerController.off('selectedSubjectsChange')
    this.visionImageAnalyzerController.off('analyzerFailed')
  }

  build() {
    Image(this.image.pixelMap, {
      types: [ImageAnalyzerType.TEXT, ImageAnalyzerType.SUBJECT, ImageAnalyzerType.OBJECT_LOOKUP],
      aiController: this.visionImageAnalyzerController
    })
      .width("100%")
      .preview(this.image)
  }
}