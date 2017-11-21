//
//  EasyPermission.m
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/16.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import "EasyPermission.h"
#import <Photos/PHPhotoLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Contacts/Contacts.h>
#import <pthread.h>
#import <EventKit/EventKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UserNotifications/UserNotifications.h>


extern inline void asyncMainQueue_block(void(^block)(void));
extern inline double currentVersion(void);

dispatch_queue_t         _concurrentQueue;
pthread_mutex_t          _photoLibrary_lock;
pthread_mutex_t          _camera_lock;
pthread_mutex_t          _addressBook_lock;
pthread_mutex_t          _microphone_lock;
pthread_mutex_t          _mediaLibrary_lock;
pthread_mutex_t          _bluetooth_lock;
pthread_mutex_t          _notifications_lock;
pthread_mutex_t          _calendar_lock;
pthread_mutex_t          _reminder_lock;
pthread_mutex_t          _location_lock;

EasyPermissionHelper     *_helper;

inline double currentVersion(){
    return [[UIDevice currentDevice].systemVersion doubleValue];
}

inline void asyncMainQueue_block(void(^block)(void)){
    if (block) {
        if ([NSThread isMainThread]) {
            block();
        }else{
            dispatch_async(_concurrentQueue, ^{
                block();
            });
        }
    }
}

@implementation  EasyPermissionHelper

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    pthread_mutex_unlock(&_location_lock);

    if (!_locationBlock) return;
    if (status == kCLAuthorizationStatusNotDetermined) return;  // first request location
    
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        asyncMainQueue_block(^{
            _locationBlock(EasyAuthorizationStatusAuthorized);
        });
    }else if (status == kCLAuthorizationStatusDenied){
        asyncMainQueue_block(^{
            _locationBlock(EasyAuthorizationStatusDenied);
        });
    }
    _lmg.delegate = nil;
}
@end


@implementation EasyPermission

+ (void)load{
    _concurrentQueue = dispatch_queue_create("com.queue.easypermission", DISPATCH_QUEUE_CONCURRENT);
    pthread_mutex_init(&_photoLibrary_lock, NULL);
    pthread_mutex_init(&_camera_lock, NULL);
    pthread_mutex_init(&_addressBook_lock, NULL);
    pthread_mutex_init(&_microphone_lock, NULL);
    pthread_mutex_init(&_mediaLibrary_lock, NULL);
    pthread_mutex_init(&_location_lock, NULL);
    pthread_mutex_init(&_bluetooth_lock, NULL);
    pthread_mutex_init(&_notifications_lock, NULL);
    pthread_mutex_init(&_calendar_lock, NULL);
    pthread_mutex_init(&_reminder_lock, NULL);
    
    _helper = [[EasyPermissionHelper alloc]init];
}

+ (void)openSetting{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (currentVersion() < 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
        }else{
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
}

+ (void)alertTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAc = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *settingAc = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openSetting];
    }];
    [alertVc addAction:closeAc];
    [alertVc addAction:settingAc];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];
}
@end
