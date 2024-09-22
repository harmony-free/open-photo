# open-photo

#### 介绍

这是一个打开相机、相册、图片的功能，可以平移、放大、缩小、双指旋转、双击放大、以及一些图片相关的工具类。

#### 软件架构

| 主要功能 | 模块     | 介绍                                 |
|------|--------|------------------------------------|
| 打开相机 | alert  | `Dialog.alert("alert")`            | 
| 打开相册 | open   | `Dialog.open({data:"open"})`       | 
| 打开图片 | sheet  | `Dialog.sheet({data:['sheet']})`   | 
| 平移   | picker | `Dialog.picker({data:['picker']})` | 
| 放大   | tel    | `Dialog.tel("168********")`        | 
| 缩小   | custom | `Dialog.custom(wrap, params)`      | 
| 双指旋转 | custom | `Dialog.custom(wrap, params)`      | 
| 双击放大 | custom | `Dialog.custom(wrap, params)`      | 
| 翻转   | custom | `Dialog.custom(wrap, params)`      | 
| 剪切   | custom | `Dialog.custom(wrap, params)`      | 

#### 安装教程

```
ohpm install @free/open-photo
```

#### 使用说明

相关权限: 该权限需要申请开通

读取影像:`ohos.permission.READ_IMAGEVIDEO`

修改影像:`ohos.permission.WRITE_IMAGEVIDEO`

1、 打开图片

```
// 注册路由
router.requestBuilder("openImage", wrapBuilder(OpenImageBuilder))

// 跳转页面 navgation
router.push('openImage', new Object({ src: "" }))

// 跳转页面 router
router.push('openImage', new Object({ src: "" }))

```

#### 参与贡献

1. Fork 本仓库
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request

#### 特技

1. 使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2. Gitee 官方博客 [blog.gitee.com](https://blog.gitee.com)
3. 你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解 Gitee 上的优秀开源项目
4. [GVP](https://gitee.com/gvp) 全称是 Gitee 最有价值开源项目，是综合评定出的优秀开源项目
5. Gitee 官方提供的使用手册 [https://gitee.com/help](https://gitee.com/help)
6. Gitee 封面人物是一档用来展示 Gitee 会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)
