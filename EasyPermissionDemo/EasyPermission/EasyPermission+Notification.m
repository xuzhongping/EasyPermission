//
//  EasyPermission+Notification.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission+Notification.h"
#import <UserNotifications/UserNotifications.h>


extern pthread_mutex_t          _mediaLibrary_lock;
extern dispatch_queue_t         _concurrentQueue;
extern inline void asyncMainQueue_block(void(^block)(void));
extern inline double currentVersion();

@implementation EasyPermission (Notification)

+ (void)checkNotificationAuthorityStatus:(StatusBlock)statusBlock{
    if (currentVersion() < 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        UIUserNotificationType notiTypes = settings.types;
        
        if (notiTypes == UIUserNotificationTypeNone) {
            asyncMainQueue_block(^{
                statusBlock == nil?:statusBlock(EasyAuthorizationStatusDenied);
            });
        }else{
            asyncMainQueue_block(^{
                statusBlock == nil?:statusBlock(EasyAuthorizationStatusAuthorized);
            });
        }
#pragma clang diagnostic pop
    }else{
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            UNAuthorizationStatus st = settings.authorizationStatus;
            EasyAuthorityStatus est;
            switch (st) {
                case UNAuthorizationStatusNotDetermined:
                {
                    est = EasyAuthorizationStatusNotDetermined;
                }
                    break;
                case UNAuthorizationStatusDenied:
                {
                    est = EasyAuthorizationStatusDenied;
                }
                    break;
                case UNAuthorizationStatusAuthorized:
                {
                    est = EasyAuthorizationStatusAuthorized;
                }
                    break;
                    
                default:
                    break;
            }
            asyncMainQueue_block(^{
                statusBlock == nil?:statusBlock(est);
            });
        }];;
    }
}
@end
