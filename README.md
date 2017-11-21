# EasyPermission

![](https://img.shields.io/badge/language-objc-orange.svg)

## 功能
1. 封装了开发中常用的权限请求的代码，使用Block进行回调处理。

## 最近更新
> 会尽快更新其他的权限访问接口


## 使用方式

    [EasyPermission requestLocationPermissionType:EasyLocationRequestTypeAlway completion:^(EasyAuthorityStatus status) {
        // your code
    }];


## 提醒
> iOS10以后，苹果增强了对用户隐私信息的保护，如果需要访问一些权限，需要在项目的info.plist里增加以下字段，对号入座:
```
<!-- 相册 --> 
<key>NSPhotoLibraryUsageDescription</key> 
<string>App需要您的同意,才能访问相册</string> 
<!-- 相机 --> 
<key>NSCameraUsageDescription</key> 
<string>App需要您的同意,才能访问相机</string> 
<!-- 麦克风 --> 
<key>NSMicrophoneUsageDescription</key> 
<string>App需要您的同意,才能访问麦克风</string> 
<!-- 位置 --> 
<key>NSLocationUsageDescription</key> 
<string>App需要您的同意,才能访问位置</string> 
<!-- 在使用期间访问位置 --> 
<key>NSLocationWhenInUseUsageDescription</key> 
<string>App需要您的同意,才能在使用期间访问位置</string> 
<!-- 始终访问位置 --> 
<key>NSLocationAlwaysUsageDescription</key> 
<string>App需要您的同意,才能始终访问位置</string> 
<!-- 日历 --> 
<key>NSCalendarsUsageDescription</key> 
<string>App需要您的同意,才能访问日历</string>
<!-- 媒体资料库 --> 
<key>NSAppleMusicUsageDescription</key> 
<string>App需要您的同意,才能访问媒体资料库</string>
```

## 联系我
> 可以将发现的问题或有好的建议告诉我，邮箱: 1021057927@qq.com

> 可以直接在此提 Issues 与 pull

> 技术交流QQ群群员招募中 ，群IDbase64:**NjA0NjA5Mjg4**

## License

EasyPermission is available under the MIT license. See the LICENSE file for more info.

