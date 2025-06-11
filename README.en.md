# open-photo

#### Description [中文](README.md)

This is a function for opening the camera, photo album and pictures. It enables you to pan, zoom in, zoom out, rotate with two fingers, double-click to enlarge, and also provides some tools related to pictures.

#### Software Architecture


| Function                | Module    | Introduction                           |
|-------------------------|-----------|----------------------------------------|
| Image component         | Completed | `ImageView`                            | 
| Open the photo album    | Completed | `PhotoPage`                            | 
| Open the picture        | Completed | `OpenImage`                            | 
| Translation             | Completed | `LongPressGesture`                     | 
| Enlargement             | Completed | `TapGesture({ count: 2, fingers: 1 })` | 
| Reduce                  | Completed | `TapGesture({ count: 2, fingers: 1 })` | 
| Two-finger rotation     | Completed | `RotationGesture`                      | 
| Double-click to enlarge | Completed | `TapGesture({ count: 2, fingers: 1 })` | 
| Flip                    | Completed | `RotationGesture`                      | 
| Cutting                 | Completed | `Dialog.custom(wrap, params)`          | 


#### Installation

```
ohpm install @free/open-photo
```

#### Instructions

Related permissions: This permission requires application for activation.

Read the image:`ohos.permission.READ_IMAGEVIDEO`

Edit the image:`ohos.permission.WRITE_IMAGEVIDEO`

1、 Open the picture.

```
// Registration Route
router.requestBuilder("openImage", wrapBuilder(OpenImageBuilder))

// Navigate to another page navgation
router.push('openImage', new Object({ src: "" }))

// Navigate to another page router 
// @Entry({ routeName: 'photoManage/OpenImage' })
// router.push('openImage', new Object({ src: "" }))
router.pushNamedRoute({name:"photoManage/OpenImage"})

```

2、Use the components directly
```
ImageView({
        src: imgSrc,
      }).width("100%")
```

#### Contribution

1.  Fork the repository
2.  Create Feat_xxx branch
3.  Commit your code
4.  Create Pull Request


#### Gitee Feature

1.  You can use Readme\_XXX.md to support different languages, such as Readme\_en.md, Readme\_zh.md
2.  Gitee blog [blog.gitee.com](https://blog.gitee.com)
3.  Explore open source project [https://gitee.com/explore](https://gitee.com/explore)
4.  The most valuable open source project [GVP](https://gitee.com/gvp)
5.  The manual of Gitee [https://gitee.com/help](https://gitee.com/help)
6.  The most popular members  [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
