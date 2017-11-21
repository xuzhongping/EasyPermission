//
//  EasyPermission+Calendar.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/21.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission+Calendar.h"
#import <EventKit/EventKit.h>

extern pthread_mutex_t          _calendar_lock;
extern dispatch_queue_t         _concurrentQueue;
extern inline void asyncMainQueue_block(void(^block)(void));


@implementation EasyPermission (Calendar)
+ (EasyAuthorityStatus)checkCalendarAuthority{
    return (EasyAuthorityStatus)[EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
}
+ (void)requestCalendarPermission:(StatusBlock)statusBlock{
    pthread_mutex_lock(&_calendar_lock);
    EasyAuthorityStatus st = [self checkCalendarAuthority];
    dispatch_async(_concurrentQueue, ^{
        switch (st) {
            case EasyAuthorizationStatusNotDetermined:
            {
                [[EKEventStore new] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                    pthread_mutex_unlock(&_calendar_lock);
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
                pthread_mutex_unlock(&_calendar_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusRestricted);
                });
            }
                break;
            case EasyAuthorizationStatusDenied:
            {
                pthread_mutex_unlock(&_calendar_lock);
                asyncMainQueue_block(^{
                    statusBlock == nil?:statusBlock(EasyAuthorizationStatusDenied);
                });
            }
                break;
            case EasyAuthorizationStatusAuthorized:
            {
                pthread_mutex_unlock(&_calendar_lock);
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
