//
//  EasyPermission+Camera.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission+Camera.h"
#import <AVFoundation/AVFoundation.h>

extern pthread_mutex_t          _camera_lock;
extern dispatch_queue_t         _concurrentQueue;
extern inline void asyncMainQueue_block(void(^block)(void));


@implementation EasyPermission (Camera)

+ (EasyAuthorityStatus)checkCameraAuthority{
    return (EasyAuthorityStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}
+ (void)requestCameraPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_camera_lock);
    EasyAuthorityStatus st = [self checkCameraAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case EasyAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    pthread_mutex_unlock(&_camera_lock);
                    EasyAuthorityStatus cst = EasyAuthorizationStatusDenied;
                    if (granted) {
                        cst = EasyAuthorizationStatusAuthorized;
                    }
                    asyncMainQueue_block(^{
                        statusBlock == nil?:statusBlock(cst);
                    });
                }];
            }
                break;
            case EasyAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_camera_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case EasyAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_camera_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case EasyAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_camera_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusAuthorized);
                });
            }
                break;
                
            default:
                break;
        }
    });
}
@end
