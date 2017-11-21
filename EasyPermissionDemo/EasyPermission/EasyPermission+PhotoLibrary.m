//
//  EasyPermission+PhotoLibrary.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission+PhotoLibrary.h"
#import <Photos/PHPhotoLibrary.h>

extern pthread_mutex_t          _photoLibrary_lock;
extern dispatch_queue_t         _concurrentQueue;
extern inline void asyncMainQueue_block(void(^block)(void));

@implementation EasyPermission (PhotoLibrary)

+ (EasyAuthorityStatus)checkPhotoLibrayAuthority{
    return (EasyAuthorityStatus)[PHPhotoLibrary authorizationStatus];
}
+ (void)requestPhotoLibrayPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_photoLibrary_lock);
    EasyAuthorityStatus st = [self checkPhotoLibrayAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case EasyAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    pthread_mutex_unlock(&_photoLibrary_lock);
                    asyncMainQueue_block(^{
                        statusBlock == nil?:statusBlock((EasyAuthorityStatus)status);
                    });
                }];
            }
                break;
            case EasyAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_photoLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case EasyAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_photoLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusDenied);
                });
                
            }
                break;
            case EasyAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_photoLibrary_lock);
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
