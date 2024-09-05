import photoAccessHelper from '@ohos.file.photoAccessHelper';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { camera, cameraPicker } from '@kit.CameraKit';

class MediaHandler implements photoAccessHelper.MediaAssetDataHandler<image.ImageSource> {
  constructor(onData: (data: image.ImageSource) => void) {
    this.onData = onData
  }

  private onData: (data: image.ImageSource) => void;

  onDataPrepared(data: image.ImageSource) {
    if (data === undefined) {
      console.error('Error occurred when preparing data');
      return;
    }
    this.onData(data)
    console.info('on image data prepared');
  }
}

class PhotoBase {
  protected context: Context = getContext()
  protected pathDir = this.context.filesDir;
  protected photoHelper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(this.context)
  protected request =
    photoAccessHelper.MediaAssetChangeRequest.createAssetRequest(this.context, photoAccessHelper.PhotoType.IMAGE,
      'png');
  protected requestOptions: photoAccessHelper.RequestOptions = {
    deliveryMode: photoAccessHelper.DeliveryMode.HIGH_QUALITY_MODE,
  }
  protected options: photoAccessHelper.FetchOptions = {
    fetchColumns: [],
    predicates: new dataSharePredicates.DataSharePredicates()
  }
  fetchResult: Promise<photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset>> =
    this.photoHelper.getAssets(this.options)
}

interface PhotoFace {
  // 图片数量
  count: number
  // 缩列图
  thumbnail: image.PixelMap[]
  // 图片列表
  photos: photoAccessHelper.PhotoAsset[]
  // 是否是最后一个
  isAfterLast: boolean
}

export class PhotoManage extends PhotoBase implements PhotoFace {
  photos: photoAccessHelper.PhotoAsset[] = []
  thumbnail: image.PixelMap[] = []
  count: number = 0
  isAfterLast: boolean = false
  requestRead: boolean = false
  requestWrite: boolean = false

  onData(data: image.ImageSource) {
    console.log('获取到图片资源, 未使用')
  }

  loadFile(asset: photoAccessHelper.PhotoAsset, onData?: (data: image.ImageSource) => void) {
    let handler = new MediaHandler(onData ?? this.onData);
    photoAccessHelper.MediaAssetManager.requestImage(this.context, asset, this.requestOptions, handler)
  }

  constructor(fetchColumns: string[] = []) {
    super()
    this.options.fetchColumns = fetchColumns
    this.fetchResult = this.photoHelper.getAssets(this.options)
  }

  async requestAssets(): Promise<photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset>> {
    if (this.requestRead) {
      await this.requestPermissions('ohos.permission.READ_IMAGEVIDEO')
    }
    return this.photoHelper.getAssets(this.options)
  }


  requestPermissions(...permissions: Array<Permissions>): Promise<boolean> {
    return new Promise<boolean>((res, rej) => {
      abilityAccessCtrl.createAtManager()
        .requestPermissionsFromUser(getContext(this), permissions).then(async (v: PermissionRequestResult) => {
        let isPermission: boolean = true
        for (let index = 0; index < v.permissions.length; index++) {
          let permission = v.permissions[index] as Permissions
          let authResult = v.authResults[index]
          if (authResult == 0) {
            if (permission == 'ohos.permission.READ_IMAGEVIDEO') {
              this.requestRead = true
            }
            if (permission == 'ohos.permission.WRITE_IMAGEVIDEO') {
              this.requestWrite = true
            }
          } else if (authResult == 1) {
            let i = permissions.indexOf(permission)
            if (i != -1) {
              isPermission = false
            }
            promptAction.showDialog({
              title: "前往设置",
              message: "该权限已被禁止，请前往系统设置开启。",
              buttons: [
                { text: "暂不", color: '#000000' },
                { text: "去设置", color: '#0000FF' }
              ]
            })
            res(isPermission)
            return
          } else if (authResult == 2) {
            let i = permissions.indexOf(permission)
            if (i != -1) {
              isPermission = await this.requestPermissions(permissions[i])
            }
          }
        }
        res(isPermission)
      })
    })
  }

  async init(): Promise<photoAccessHelper.PhotoAsset[]> {
    return new Promise<photoAccessHelper.PhotoAsset[]>((res, rej) => {
      this.fetchResult.then((r) => {
        this.count = r.getCount()
        this.isAfterLast = r.isAfterLast()
        r.getAllObjects().then((ps) => {
          this.photos = ps
          console.log(JSON.stringify(ps))
          res(ps)
          r.close()
        })
      }).catch((err: Error) => {
        console.log(JSON.stringify(err))
      })
    })
  }

  createUri(extension: string = 'png'): Promise<string> {
    return this.photoHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, extension, { title: 'testPhoto' })
  }

  create(resource: string | ArrayBuffer) {
    if (typeof resource == 'string') {
      this.request.addResource(photoAccessHelper.ResourceType.IMAGE_RESOURCE, resource)
    } else {
      this.request.addResource(photoAccessHelper.ResourceType.IMAGE_RESOURCE, resource)
    }
    this.photoHelper.applyChanges(this.request);
  }

  delete(uris: string[]) {
    try {
      photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), uris);
      console.info('deleteAssets successfully');
    } catch (err) {
      console.error(`deleteAssetsDemo failed with error: ${err.code}, ${err.message}`);
    }
  }

  release() {
    this.photoHelper.release((err) => {
      if (err !== undefined) {
        console.error(`release failed. error: ${err.code}, ${err.message}`);
      } else {
        console.info('release ok.');
      }
    });
  }
}

/**
 * 打开系统相机或相册
 */
export class CameraPhoto {
  photoPicker = new photoAccessHelper.PhotoViewPicker();
  photoUris: Array<string> = []

  /**
   * 打开系统相册
   */
  photo(options: photoAccessHelper.PhotoSelectOptions = {
    maxSelectNumber: 50,
    preselectedUris: this.photoUris
  } as photoAccessHelper.PhotoSelectOptions): Promise<Array<string>> {
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    return new Promise<Array<string>>((res, rej) => {
      try {
        this.photoPicker.select(options)
          .then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
            this.photoUris = photoSelectResult.photoUris
            res(photoSelectResult.photoUris)
            console.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' +
            JSON.stringify(photoSelectResult))
          })
          .catch((err: BusinessError) => {
            rej(err)
            console.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
          });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        rej(err)
        console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
      }
    })

  }

  /**
   * 打开系统相机
   */
  camera(mContext: common.Context): Promise<string> {
    return new Promise<string>((res, rej) => {
      try {
        let profile: cameraPicker.PickerProfile = {
          cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK
        };
        cameraPicker.pick(mContext, [cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO], profile)
          .then((result) => {
            if (result.resultCode == 0) {
              res(result.resultUri)
            } else {
              rej(new Error('clean cameraPicker'))
            }
          })
          .catch((err: BusinessError) => {
            rej(err)
            console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
          });
      } catch (error) {
        let err = error as BusinessError;
        rej(err)
        console.error(`the pick call failed. error code: ${err.code}`);
      }
    })
  }
}


