//
//  EasyPermission.h
//  EasyPermissionDemo
//
//  Created by JungHsu on 2017/11/16.
//  Copyright © 2017年 JungHsu. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,EasyAuthorityStatus){
    EasyAuthorizationStatusNotDetermined = 0,
    EasyAuthorizationStatusRestricted = 1,
    EasyAuthorizationStatusDenied = 2,
    EasyAuthorizationStatusAuthorized = 3,
    EasyAuthorizationStatusTurnOff = 4
};

typedef NS_ENUM(NSInteger,EasyLocationRequestType){
    EasyLocationRequestTypeWhenIn = 0,
    EasyLocationRequestTypeAlway = 1
};

typedef void(^StatusBlock)(EasyAuthorityStatus status);


@interface EasyPermission : NSObject


@end

@interface EasyPermission(PhotoLibray)
+ (EasyAuthorityStatus)checkPhotoLibrayAuthority;
+ (void)requestPhotoLibrayPermission:(StatusBlock)statusBlock;
@end


@interface EasyPermission(Camera)
+ (EasyAuthorityStatus)checkCameraAuthority;
+ (void)requestCameraPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(AddressBook)
+ (EasyAuthorityStatus)checkAddressBookAuthority;
+ (void)requestAddressBookPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Microphone)
+ (EasyAuthorityStatus)checkMicrophoneAuthority;
+ (void)requestMicrophonePermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(MediaLibrary)
+ (EasyAuthorityStatus)checkMediaLibraryAuthority;
+ (void)requestMediaLibraryPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Location)
+ (EasyAuthorityStatus)checkLocationAuthority;
+ (void)requestLocationPermissionType:(EasyLocationRequestType)type completion:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Notification)

@end

@interface EasyPermission(Calendar)
+ (EasyAuthorityStatus)checkCalendarAuthority;
+ (void)requestCalendarPermission:(StatusBlock)statusBlock;
@end

@interface EasyPermission(Reminder)
+ (EasyAuthorityStatus)checkReminderAuthority;
+ (void)requestReminderPermission:(StatusBlock)statusBlock;
@end


