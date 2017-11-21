//
//  EasyPermission+MediaLibrary.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission+MediaLibrary.h"
#import <MediaPlayer/MediaPlayer.h>

extern pthread_mutex_t          _mediaLibrary_lock;
extern dispatch_queue_t         _concurrentQueue;
extern inline void asyncMainQueue_block(void(^block)(void));

@implementation EasyPermission (MediaLibrary)


+ (EasyAuthorityStatus)checkMediaLibraryAuthority{
    MPMediaLibraryAuthorizationStatus st = [MPMediaLibrary authorizationStatus];
    switch (st) {
        case MPMediaLibraryAuthorizationStatusNotDetermined:
        {
            return EasyAuthorizationStatusNotDetermined;
        }
            break;
        case MPMediaLibraryAuthorizationStatusDenied:
        {
            return EasyAuthorizationStatusNotDetermined;
        }
            break;
        case MPMediaLibraryAuthorizationStatusRestricted:
        {
            return EasyAuthorizationStatusRestricted;
        }
            break;
        case MPMediaLibraryAuthorizationStatusAuthorized:
        {
            return EasyAuthorizationStatusAuthorized;
        }
            break;
            
        default:
            break;
    }
}
+ (void)requestMediaLibraryPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_mediaLibrary_lock);
    EasyAuthorityStatus st = [self checkMediaLibraryAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case EasyAuthorizationStatusNotDetermined:
            {
                [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                    pthread_mutex_unlock(&_mediaLibrary_lock);
                    asyncMainQueue_block(^{
                        statusBlock == nil?:statusBlock((EasyAuthorityStatus)status);
                    });
                }];
            }
                break;
            case EasyAuthorizationStatusRestricted:
            {
                pthread_mutex_unlock(&_mediaLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case EasyAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_mediaLibrary_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case EasyAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_mediaLibrary_lock);
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
